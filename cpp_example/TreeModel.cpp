#include "TreeModel.h"

TreeModel::TreeModel(QObject *parent) :
    QAbstractListModel(parent),
    nextUid(10)
{
}

int TreeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return items.size();
}

QVariant TreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= items.size()) {
        return {};
    }

    return fieldFromItem(items.at(index.row()), role);
}

bool TreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= items.size()) {
        return false;
    }

    if (!setFieldOnItem(items[index.row()], role, value)) {
        return false;
    }

    emit dataChanged(index, index, {role});
    return true;
}

bool TreeModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (parent.isValid() || row < 0 || count < 1 || row + count > items.size()) {
        return false;
    }

    beginRemoveRows(QModelIndex(), row, row + count - 1);
    items.remove(row, count);
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

QVariantMap TreeModel::get(int row) const
{
    QVariantMap map;
    if (row < 0 || row >= items.size()) {
        return map;
    }

    const TreeItem &item = items.at(row);
    map[QStringLiteral("uid")]          = item.uid;
    map[QStringLiteral("title")]        = item.title;
    map[QStringLiteral("isFolder")]     = item.isFolder;
    map[QStringLiteral("parentFolder")] = item.parentFolder;
    map[QStringLiteral("folderOpen")]   = item.folderOpen;
    map[QStringLiteral("dropTarget")]   = item.dropTarget;
    map[QStringLiteral("draggable")]    = item.draggable;
    return map;
}

void TreeModel::setProperty(int row, const QString &name, QVariant value)
{
    if (row < 0 || row >= items.size()) {
        return;
    }

    int role = roleFromFieldName(name);
    if (role < 0) {
        return;
    }

    if (!setFieldOnItem(items[row], role, value)) {
        return;
    }

    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {role});
}

void TreeModel::move(int from, int to, int count)
{
    // Move count items one at a time to match QML ListModel behavior.
    for (int i = 0; i < count; ++i) {
        int src = (to > from) ? from : from + i;
        int dst = (to > from) ? to + i : to + i;
        if (src < 0 || src >= items.size() || dst < 0 || dst >= items.size() || src == dst) {
            continue;
        }

        int dest = (dst > src) ? dst + 1 : dst;
        beginMoveRows(QModelIndex(), src, src, QModelIndex(), dest);
        items.move(src, dst);
        endMoveRows();
    }
}

void TreeModel::remove(int row, int count)
{
    removeRows(row, count);
}

int TreeModel::insertFolder(int atIndex)
{
    if (atIndex < 0 || atIndex > items.size()) {
        atIndex = items.size();
    }

    int uid = nextUid++;
    TreeItem folder;
    folder.uid = uid;
    folder.title = QStringLiteral("New folder");
    folder.isFolder = true;
    folder.parentFolder = -1;
    folder.folderOpen = true;
    folder.dropTarget = QStringLiteral("none");
    folder.draggable = true;

    beginInsertRows(QModelIndex(), atIndex, atIndex);
    items.insert(atIndex, folder);
    endInsertRows();
    emit countChanged();
    return uid;
}

void TreeModel::addItem(const TreeItem &item)
{
    int row = items.size();
    beginInsertRows(QModelIndex(), row, row);
    items.append(item);
    endInsertRows();

    // Keep m_nextUid ahead of any manually-added UIDs.
    if (item.uid >= nextUid) {
        nextUid = item.uid + 1;
    }

    emit countChanged();
}

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
