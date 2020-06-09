package com.greg.viewer.tree;

import java.util.List;

public class DummyNode extends TreeNode {
	public DummyNode() {
	}

	@Override
	public String getFilePath() {
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
	public String getContent() {
		return "";
	}

	@Override
	public void loadChildren() {

	}

	@Override
	public TreeNode getParentNode() {
		return this;
	}

	@Override
	public String toString() {
		return "";
	}

}
