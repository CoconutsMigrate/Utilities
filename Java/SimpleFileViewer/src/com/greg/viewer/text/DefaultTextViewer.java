package com.greg.viewer.text;

import com.greg.viewer.SimpleFileViewer;
import com.greg.viewer.tree.TreeNode;

import javax.swing.*;
import java.awt.*;
import java.util.Objects;

public class DefaultTextViewer implements TextViewer {
	private final JTextArea text;
	private final JScrollPane pane;

	public DefaultTextViewer() {
		text = new JTextArea();
		text.setFont(new Font("courier new", Font.PLAIN, 14));
		pane = new JScrollPane(text);
	}

	@Override
	public void displayText(String text) {
		this.text.setText(text);
	}

	@Override
	public void displayFile(TreeNode node) {
		try {
			String content = Objects.toString(node.getContent(), "");
			if (content.length() > 50000) {
				content = content.substring(0, 50000);
			}
			text.setText(content);
			text.setCaretPosition(0);
		} catch (Exception e) {
			text.setText(SimpleFileViewer.formatException(e));
		}
	}

	@Override
	public void displayFileFull(TreeNode node) {
		try {
			String content = Objects.toString(node.getContent(), "");
			text.setText(content);
			text.setCaretPosition(0);
		} catch (Exception e) {
			text.setText(SimpleFileViewer.formatException(e));
		}
	}

	@Override
	public Component getTextComponent() {
		return pane;
	}
}
