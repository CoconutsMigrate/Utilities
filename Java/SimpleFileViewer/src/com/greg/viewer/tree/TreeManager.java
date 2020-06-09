package com.greg.viewer.tree;

import com.greg.viewer.text.TextViewer;

import javax.swing.*;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeSelectionModel;
import java.awt.datatransfer.DataFlavor;
import java.awt.dnd.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class TreeManager implements TreeSelectionListener {
	private TreeNode rootNode;
	private final JTree tree;
	private final TextViewer viewer;

	public TreeManager(TextViewer viewer) {
		this.viewer = viewer;
		tree = new JTree(new DummyNode());
		tree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
		tree.addTreeSelectionListener(this);
		tree.setDragEnabled(true);
		DropTarget target = new DropTarget(tree, new DropTargetAdapter() {
			@Override
			public void drop(DropTargetDropEvent e) {
				try {
					e.acceptDrop(DnDConstants.ACTION_COPY_OR_MOVE);
					List list = (List) e.getTransferable().getTransferData(DataFlavor.javaFileListFlavor);

					if (list.size() == 1) {
						File file = (File) list.get(0);
						if (file.isDirectory()) {
							setTreePath(file);
						} else if (file.isFile()) {
							setTreeArchive(file);
						}
					}

				} catch (Exception ex) {
				}
			}
		});
		rootNode = new DummyNode();
	}

	public void setTreePath(File path) {
		if (path != null && path.isDirectory()) {
			rootNode = new FolderNode(path, null);
			rootNode.loadChildren();
			DefaultTreeModel model = (DefaultTreeModel) tree.getModel();
			model.setRoot(rootNode);
		}
	}

	public void setTreePath(TreeNode node) {
		if (node != null && node.isFolder()) {
			rootNode = node;
			DefaultTreeModel model = (DefaultTreeModel) tree.getModel();
			model.setRoot(rootNode);
		}
	}


	public void setTreeArchive(File archivePath) {
		if (archivePath != null && archivePath.isFile()) {
			try (ZipInputStream zis = new ZipInputStream(Files.newInputStream(archivePath.toPath()))) {
				for (ZipEntry entry = zis.getNextEntry(); entry != null; entry = zis.getNextEntry()) {
					System.out.println("Name: " + entry.getName() + ", Dir: " + entry.isDirectory());
					if (!entry.isDirectory()) {
						String text = readFromArchive(zis).toString();
						System.out.println(text);
					}
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
			rootNode = new FolderNode(archivePath, null);
			processArchiveChildren(rootNode);
		}
	}

	public StringBuilder readFromArchive(ZipInputStream zis) {
		StringBuilder s = new StringBuilder();
		try {
			byte[] buffer = new byte[1024];
			int read = 0;
			while ((read = zis.read(buffer, 0, 1024)) >= 0) {
				s.append(new String(buffer, 0, read));
			}
		} catch (IOException ex) {

		}
		return s;
	}

	private void processArchiveChildren(TreeNode node) {

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