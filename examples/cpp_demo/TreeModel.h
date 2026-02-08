#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractListModel>
#include <QList>

struct TreeItem {
    int uid = 0;
    QString title;
    bool isFolder = false;
    int parentFolder = -1;
    bool folderOpen = true;
    QString dropTarget = QStringLiteral("none");
    bool draggable = true;
};

class TreeModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role {
        UidRole = Qt::UserRole + 1,
        TitleRole,
        IsFolderRole,
        ParentFolderRole,
        FolderOpenRole,
        DropTargetRole,
        DraggableRole
    };
    Q_ENUM(Role)

    explicit TreeModel(QObject *parent = nullptr);

    // QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    QHash<int, QByteArray> roleNames() const override;

    // count property
    int count() const;

    // QML-facing API (matches RearrangeableDelegate expectations for qmlListModel: false)
    Q_INVOKABLE QVariant dataByField(int row, const QString &fieldName) const;
    Q_INVOKABLE void setData(int row, const QString &fieldName, QVariant newValue);
    Q_INVOKABLE void move(int from, int to);
    Q_INVOKABLE bool removeRow(int row);
    Q_INVOKABLE int insertFolder(int atIndex);

    // Convenience for populating from C++
    void addItem(const TreeItem &item);

signals:
    void countChanged();

private:
    QList<TreeItem> m_items;
    int m_nextUid = 10;

    int roleFromFieldName(const QString &fieldName) const;
    QVariant fieldFromItem(const TreeItem &item, int role) const;
    bool setFieldOnItem(TreeItem &item, int role, const QVariant &value);
};

#endif // TREEMODEL_H
