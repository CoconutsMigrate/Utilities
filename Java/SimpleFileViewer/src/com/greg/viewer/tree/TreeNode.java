package com.greg.viewer.tree;

import javax.swing.tree.DefaultMutableTreeNode;
import java.io.File;

public abstract class TreeNode extends DefaultMutableTreeNode {
    public abstract String getFilePath();
    public abstract File getFile();
    public abstract boolean isFile();
    public abstract boolean isFolder();

    public FolderNode getAsFolderNode() {
        return (FolderNode)this;
    }

    public FileNode getAsFileNode() {
        return (FileNode)this;
    }
}
