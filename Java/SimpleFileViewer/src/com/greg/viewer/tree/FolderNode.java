package com.greg.viewer.tree;

import java.io.File;

public class FolderNode extends TreeNode {
	private final File folder;
	private final TreeNode parent;

	public FolderNode(File folder, TreeNode parent) {
		if (folder == null || !folder.isDirectory()) {
			throw new Error(folder + " is not a folder");
		}
		this.folder = folder;
		this.parent = parent;
	}

	@Override
	public String getFilePath() {
		return folder.getPath();
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
		return "";
	}

	@Override
	public void loadChildren() {
		if (folder != null && folder.listFiles() != null) {
			for (File child : folder.listFiles()) {
				if (child.isDirectory()) {
					FolderNode folderNode = new FolderNode(child, this);
					add(folderNode);
					folderNode.loadChildren();
				} else if (child.isFile()) {
					add(new FileNode(child, this));
				}
			}
		}
	}

	@Override
	public TreeNode getParentNode() {
		return parent;
	}

	@Override
	public String toString() {
		return folder.getName();
	}
}
