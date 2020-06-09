package com.greg.viewer.text;

import com.greg.viewer.tree.FileNode;

import java.awt.*;

public interface TextViewer {
    void displayFile(FileNode file);
    void displayFileFull(FileNode file);
    Component getTextComponent();
}
