package com.greg.viewer.tree;

public class ArchiveFolderNode extends TreeNode {
	private static final long serialVersionUID = 1L;
	private final String path;
	private final TreeNode parent;

	public ArchiveFolderNode(String path, TreeNode parent) {
		this.path = path;
		this.parent = parent;
	}

	@Override
	public String getFilePath() {
		return path;
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
	public String getContent() {
		return null;
	}

	@Override
	public void loadChildren() {

	}

	@Override
	public TreeNode getParentNode() {
		return parent;
	}

	@Override
	public String toString() {
		return path;
	}
}
