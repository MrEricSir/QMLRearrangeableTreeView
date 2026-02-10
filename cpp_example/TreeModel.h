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

    // QAbstractListModel overrides.
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    QHash<int, QByteArray> roleNames() const override;

    // count property
    int count() const;

    // QML-facing API matches the QML ListModel of ease of use.
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE void setProperty(int row, const QString &name, QVariant value);
    Q_INVOKABLE void move(int from, int to, int count = 1);
    Q_INVOKABLE void remove(int row, int count = 1);
    Q_INVOKABLE int insertFolder(int atIndex);

    // Convenience method used in main.cpp.
    void addItem(const TreeItem &item);

signals:
    void countChanged();

private:
    int roleFromFieldName(const QString &fieldName) const;
    QVariant fieldFromItem(const TreeItem &item, int role) const;
    bool setFieldOnItem(TreeItem &item, int role, const QVariant &value);

    QList<TreeItem> items;
    int nextUid;
};

#endif // TREEMODEL_H
