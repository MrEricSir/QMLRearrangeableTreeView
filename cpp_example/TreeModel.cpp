#include "TreeModel.h"

TreeModel::TreeModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int TreeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant TreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};
    return fieldFromItem(m_items.at(index.row()), role);
}

bool TreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return false;
    if (!setFieldOnItem(m_items[index.row()], role, value))
        return false;
    emit dataChanged(index, index, {role});
    return true;
}

bool TreeModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (parent.isValid() || row < 0 || count < 1 || row + count > m_items.size())
        return false;
    beginRemoveRows(QModelIndex(), row, row + count - 1);
    m_items.remove(row, count);
    endRemoveRows();
    emit countChanged();
    return true;
}

QHash<int, QByteArray> TreeModel::roleNames() const
{
    return {
        {UidRole,          "uid"},
        {TitleRole,        "title"},
        {IsFolderRole,     "isFolder"},
        {ParentFolderRole, "parentFolder"},
        {FolderOpenRole,   "folderOpen"},
        {DropTargetRole,   "dropTarget"},
        {DraggableRole,    "draggable"}
    };
}

int TreeModel::count() const
{
    return rowCount();
}

// ---------------------------------------------------------------------------
// QML-facing API
// ---------------------------------------------------------------------------

QVariant TreeModel::dataByField(int row, const QString &fieldName) const
{
    if (row < 0 || row >= m_items.size())
        return {};
    int role = roleFromFieldName(fieldName);
    if (role < 0)
        return {};
    return fieldFromItem(m_items.at(row), role);
}

void TreeModel::setData(int row, const QString &fieldName, QVariant newValue)
{
    if (row < 0 || row >= m_items.size())
        return;
    int role = roleFromFieldName(fieldName);
    if (role < 0)
        return;
    if (!setFieldOnItem(m_items[row], role, newValue))
        return;
    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {role});
}

void TreeModel::move(int from, int to)
{
    if (from < 0 || from >= m_items.size() || to < 0 || to >= m_items.size() || from == to)
        return;

    // beginMoveRows quirk: when moving down, destination must be to + 1
    // because Qt defines it as "the row the item will end up before."
    int dest = (to > from) ? to + 1 : to;
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), dest);
    m_items.move(from, to);
    endMoveRows();
}

bool TreeModel::removeRow(int row)
{
    return removeRows(row, 1);
}

int TreeModel::insertFolder(int atIndex)
{
    if (atIndex < 0 || atIndex > m_items.size())
        atIndex = m_items.size();

    int uid = m_nextUid++;
    TreeItem folder;
    folder.uid = uid;
    folder.title = QStringLiteral("New folder");
    folder.isFolder = true;
    folder.parentFolder = -1;
    folder.folderOpen = true;
    folder.dropTarget = QStringLiteral("none");
    folder.draggable = true;

    beginInsertRows(QModelIndex(), atIndex, atIndex);
    m_items.insert(atIndex, folder);
    endInsertRows();
    emit countChanged();
    return uid;
}

// ---------------------------------------------------------------------------
// Convenience
// ---------------------------------------------------------------------------

void TreeModel::addItem(const TreeItem &item)
{
    int row = m_items.size();
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(item);
    endInsertRows();

    // Keep m_nextUid ahead of any manually-added UIDs.
    if (item.uid >= m_nextUid)
        m_nextUid = item.uid + 1;

    emit countChanged();
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

int TreeModel::roleFromFieldName(const QString &fieldName) const
{
    static const QHash<QString, int> map = {
        {QStringLiteral("uid"),          UidRole},
        {QStringLiteral("title"),        TitleRole},
        {QStringLiteral("isFolder"),     IsFolderRole},
        {QStringLiteral("parentFolder"), ParentFolderRole},
        {QStringLiteral("folderOpen"),   FolderOpenRole},
        {QStringLiteral("dropTarget"),   DropTargetRole},
        {QStringLiteral("draggable"),    DraggableRole}
    };
    return map.value(fieldName, -1);
}

QVariant TreeModel::fieldFromItem(const TreeItem &item, int role) const
{
    switch (role) {
    case UidRole:          return item.uid;
    case TitleRole:        return item.title;
    case IsFolderRole:     return item.isFolder;
    case ParentFolderRole: return item.parentFolder;
    case FolderOpenRole:   return item.folderOpen;
    case DropTargetRole:   return item.dropTarget;
    case DraggableRole:    return item.draggable;
    default:               return {};
    }
}

bool TreeModel::setFieldOnItem(TreeItem &item, int role, const QVariant &value)
{
    switch (role) {
    case UidRole:          item.uid = value.toInt(); break;
    case TitleRole:        item.title = value.toString(); break;
    case IsFolderRole:     item.isFolder = value.toBool(); break;
    case ParentFolderRole: item.parentFolder = value.toInt(); break;
    case FolderOpenRole:   item.folderOpen = value.toBool(); break;
    case DropTargetRole:   item.dropTarget = value.toString(); break;
    case DraggableRole:    item.draggable = value.toBool(); break;
    default:               return false;
    }
    return true;
}
