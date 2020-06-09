package com.greg.viewer.tree;

public class ArchiveFileNode extends TreeNode {
	private final String path;
	private final String content;
	private final TreeNode parent;

	public ArchiveFileNode(String path, String content, TreeNode parent) {
		this.path = path;
		this.content = content;
		this.parent = parent;
	}

	@Override
	public String getFilePath() {
		return path;
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
	public String getContent() {
		return content;
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
