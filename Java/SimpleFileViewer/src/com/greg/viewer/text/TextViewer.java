package com.greg.viewer.text;

import com.greg.viewer.tree.TreeNode;

import java.awt.*;

public interface TextViewer {
	void displayText(String text);
	
	void displayFile(TreeNode node);

	void displayFileFull(TreeNode node);

	Component getTextComponent();
}
