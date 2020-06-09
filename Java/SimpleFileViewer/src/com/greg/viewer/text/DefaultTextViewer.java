package com.greg.viewer.text;

import com.greg.viewer.tree.FileNode;

import javax.swing.*;
import java.awt.*;

public class DefaultTextViewer implements TextViewer {
	private JTextArea text;
	private JScrollPane pane;

	public DefaultTextViewer() {
		text = new JTextArea();
		text.setFont(new Font("courier new", Font.PLAIN, 14));
		pane = new JScrollPane(text);
	}

	@Override
	public void displayFile(FileNode node) {
		String content = node.getContent();
		if (content.length() > 50000) {
			content = content.substring(0, 50000);
		}
		text.setText(content);
		text.setCaretPosition(0);
	}

	@Override
	public void displayFileFull(FileNode node) {
		String content = node.getContent();
		text.setText(content);
	}

	@Override
	public Component getTextComponent() {
		return pane;
	}
}
