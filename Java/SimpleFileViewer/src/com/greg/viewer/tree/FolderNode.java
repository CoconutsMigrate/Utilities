package com.greg.viewer.tree;

import javax.swing.tree.DefaultMutableTreeNode;
import java.io.File;

public class FolderNode extends TreeNode {
    private File folder;

    public FolderNode(File folder) {
        this.folder = folder;
    }

    @Override
    public String getFilePath() {
        return folder.getPath();
    }

    @Override
    public File getFile() {
        return folder;
    }

    @Override
    public boolean isFile() {
        return false;
    }

    @Override
    public boolean isFolder() {
        return true;
    }

    @Override
    public String toString() {
        return folder.getName();
    }
}
