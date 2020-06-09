package com.greg.viewer.tree;

import javax.swing.tree.DefaultMutableTreeNode;
import java.io.File;

public class DummyNode extends TreeNode {
    public DummyNode() { }

    @Override
    public String getFilePath() {
        return null;
    }

    @Override
    public File getFile() {
        return null;
    }

    @Override
    public boolean isFile() {
        return false;
    }

    @Override
    public boolean isFolder() {
        return false;
    }

    @Override
    public String toString() {
        return "";
    }

}
