package com.greg.viewer;

import com.greg.viewer.text.DefaultTextViewer;
import com.greg.viewer.text.TextViewer;
import com.greg.viewer.tree.TreeManager;
import com.greg.viewer.tree.TreeNode;

import javax.swing.*;
import java.awt.*;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.IOException;

public class SimpleFileViewer {
	private JFrame frame = new JFrame("SimpleFileViewer");
	private Component tree;
	private Component text;
	private JSplitPane splitter;
	private TreeManager treeMan;
	private TextViewer textView;

	public SimpleFileViewer() {

	}

	private void initViewerAndTree() {
		// default txt
		textView = new DefaultTextViewer();
		text = textView.getTextComponent();
		treeMan = new TreeManager(textView);
		tree = treeMan.getTree();
	}

	private void initMenus() {
		JMenuBar menubar = new JMenuBar();

		JMenu file = new JMenu("File");
		menubar.add(file);

		JMenuItem open = new JMenuItem("Open folder");
		open.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_O, InputEvent.CTRL_DOWN_MASK));
		file.add(open);
		open.addActionListener(e -> selectFolder());

		JMenuItem exit = new JMenuItem("Exit");
		file.add(exit);
		exit.addActionListener(e -> System.exit(0));


		JMenu actions = new JMenu("Actions");
		menubar.add(actions);

		JMenuItem openDefault = new JMenuItem("Open with default app");
		actions.add(openDefault);
		openDefault.addActionListener(e -> {
			try {
				Desktop.getDesktop().open(new File(treeMan.getCurrentNode().getFilePath()));
			} catch (IOException ioException) {
				ioException.printStackTrace();
			}
		});


		JMenu navigate = new JMenu("Navigate");
		menubar.add(navigate);

		JMenuItem setAsRoot = new JMenuItem("Set as Root Folder");
		navigate.add(setAsRoot);
		setAsRoot.addActionListener(e -> treeMan.setTreePath(treeMan.getCurrentNode()));

		JMenuItem navigateUp = new JMenuItem("Navigate up one level");
		navigate.add(navigateUp);
		navigateUp.addActionListener(e -> treeMan.setTreePath(treeMan.getRootNode().getParentNode()));

		frame.setJMenuBar(menubar);
	}

	private void selectFolder() {
		JFileChooser fc = new JFileChooser();
		fc.setDialogTitle("Select folder");
		fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

		if (treeMan.getRootNode().getFilePath() != null) {
			fc.setCurrentDirectory(new File(treeMan.getRootNode().getFilePath()));
		} else {
			fc.setCurrentDirectory(new File(System.getProperty("user.dir")));
		}
		int retval = fc.showOpenDialog(frame);
		if (retval == JFileChooser.APPROVE_OPTION) {
			File file = fc.getSelectedFile();
			treeMan.setTreePath(file);
		}
	}

	private void init(String path) {
		initViewerAndTree();
		initMenus();

		splitter = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
		splitter.add(tree);
		splitter.add(text);

		frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		frame.setSize(800, 600);
		frame.add(splitter);
		frame.setVisible(true);
		splitter.setDividerLocation(0.4);

		if (path != null && new File(path).isDirectory()) {
			treeMan.setTreePath(new File(path));
		}
	}

	public static void main(String args[]) {
		new SimpleFileViewer().init(String.join(" ", args));
	}
}
