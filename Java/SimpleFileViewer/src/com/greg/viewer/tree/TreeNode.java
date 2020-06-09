package com.greg.viewer.tree;

import javax.swing.tree.DefaultMutableTreeNode;
import java.util.List;

public abstract class TreeNode extends DefaultMutableTreeNode {
	public abstract String getFilePath();

	public abstract boolean isFile();

	public abstract boolean isFolder();

	public abstract String getContent();

	public abstract void loadChildren();

	public abstract TreeNode getParentNode();

	public FolderNode getAsFolderNode() {
		return (FolderNode) this;
	}

	public FileNode getAsFileNode() {
		return (FileNode) this;
	}
}
