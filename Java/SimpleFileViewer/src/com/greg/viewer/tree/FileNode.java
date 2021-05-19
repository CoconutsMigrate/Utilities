package com.greg.viewer.tree;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public class FileNode extends TreeNode {
	private static final long serialVersionUID = 1L;
	private final File file;
	private final TreeNode parent;

	public FileNode(File file, TreeNode parent) {
		this.file = file;
		this.parent = parent;
	}

	@Override
	public String getFilePath() {
		return file.getPath();
	}

	@Override
	public boolean isFile() {
		return true;
	}

	@Override
	public boolean isFolder() {
		return false;
	}

	@Override
	public String getContent() {
		try {
			return readFileContent(file.getPath());
		} catch (IOException e) {
			return file.getPath();
		}
	}

	@Override
	public void loadChildren() {}

	@Override
	public TreeNode getParentNode() {
		return parent;
	}

	@Override
	public String toString() {
		return file.getName();
	}
	
	private static String readFileContent(String filePath) throws IOException 
    {
        StringBuilder contentBuilder = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
	        String sCurrentLine;
	        while ((sCurrentLine = br.readLine()) != null) 
	        {
	            contentBuilder.append(sCurrentLine).append("\n");
	        }
        }
        return contentBuilder.toString();
    }

}
