package com.greg.viewer.text;

import com.greg.viewer.tree.FileNode;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;
import java.nio.file.Files;

public class DefaultTextViewer implements TextViewer {
    private JTextArea text;
    private JScrollPane pane;

    public DefaultTextViewer() {
        text = new JTextArea();
        text.setFont(new Font("courier new", Font.PLAIN, 14));
        pane = new JScrollPane(text);
    }

    private String tryReadContent(FileNode file) {
        try {
            return Files.readString(file.getFile().toPath());
        } catch (IOException e) {
            return file.getFilePath();
        }
    }

    @Override
    public void displayFile(FileNode file) {
        String content = tryReadContent(file);
        if (content.length() > 50000) {
            content = content.substring(0, 50000);
        }
        text.setText(content);
    }

    @Override
    public void displayFileFull(FileNode file) {
        String content = tryReadContent(file);
        text.setText(content);
    }

    @Override
    public Component getTextComponent() {
        return pane;
    }
}
