package com.greg.viewer.tree;

import javax.swing.tree.DefaultMutableTreeNode;

public abstract class TreeNode extends DefaultMutableTreeNode {
	private static final long serialVersionUID = 1L;

	public abstract String getFilePath();

	public abstract boolean isFile();

	public abstract boolean isFolder();

	public abstract String getContent();

	public abstract void loadChildren();

	public abstract TreeNode getParentNode();

	public FolderNode getAsFolderNode() {
		return (FolderNode) this;
	}
}
