package com.greg.viewer.tree;

import com.greg.viewer.text.TextViewer;

import javax.swing.*;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeSelectionModel;
import java.io.File;

public class TreeManager implements TreeSelectionListener {
    private TreeNode rootNode;
    private final JTree tree;
    private final TextViewer viewer;

    public TreeManager(TextViewer viewer) {
        this.viewer = viewer;
        tree = new JTree(new DummyNode());
        tree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
        tree.addTreeSelectionListener(this);
        rootNode = new DummyNode();
    }

    public void setTreePath(File path) {
        if (path != null && path.isDirectory()) {
            rootNode = new FolderNode(path);
            processChildren(rootNode);
            DefaultTreeModel model = (DefaultTreeModel) tree.getModel();
            model.setRoot(rootNode);
        }
    }

    private void processChildren(TreeNode node) {
        //System.out.println(node != null ? node.getFile().getPath() : "null");
        if (node.getFile() != null && node.getFile().listFiles() != null) {
            for (File child : node.getFile().listFiles()) {
                if (child.isDirectory()) {
                    FolderNode folderNode = new FolderNode(child);
                    node.add(folderNode);
                    processChildren(folderNode);
                } else if (child.isFile()) {
                    node.add(new FileNode(child));
                }
            }
        }
    }

    public JTree getTree() {
        return tree;
    }

    public TreeNode getRootNode() {
        return rootNode;
    }

    public TreeNode getCurrentNode() {
        return (TreeNode) tree.getLastSelectedPathComponent();
    }

    @Override
    public void valueChanged(TreeSelectionEvent e) {
        TreeNode node = getCurrentNode();
        if (node != null && node.isFile()) {
            fileSelected(node.getAsFileNode());
        }
    }

    private void fileSelected(FileNode node) {
        System.out.println(node.toString());
        viewer.displayFile(node);
    }
}
