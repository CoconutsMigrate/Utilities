package com.greg.viewer.text;

import com.greg.viewer.tree.FileNode;

import java.awt.*;

public interface TextViewer {
	void displayFile(FileNode node);

	void displayFileFull(FileNode node);

	Component getTextComponent();
}
