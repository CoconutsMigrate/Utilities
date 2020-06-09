package com.greg.viewer.tree;

import javax.swing.tree.DefaultMutableTreeNode;
import java.io.File;

public class FileNode extends TreeNode {
    private File file;

    public FileNode(File file) {
        this.file = file;
    }

    @Override
    public String getFilePath() {
        return file.getPath();
    }

    @Override
    public File getFile() {
        return file;
    }

    @Override
    public boolean isFile() {
        return true;
    }

    @Override
    public boolean isFolder() {
        return false;
    }

    @Override
    public String toString() {
        return file.getName();
    }

}
