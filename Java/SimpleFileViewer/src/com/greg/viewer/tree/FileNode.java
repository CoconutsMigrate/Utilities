package com.greg.viewer.tree;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

public class FileNode extends TreeNode {
	private final File file;
	private final TreeNode parent;

	public FileNode(File file, TreeNode parent) {
		this.file = file;
		this.parent = parent;
	}

	@Override
	public String getFilePath() {
		return file.getPath();
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
		try {
			return Files.readString(file.toPath());
		} catch (IOException e) {
			return file.getPath();
		}
	}

	@Override
	public void loadChildren() {}

	@Override
	public TreeNode getParentNode() {
		return parent;
	}

	@Override
	public String toString() {
		return file.getName();
	}

}
