package com.greg.viewer.common;

public class Util {
	public static final String getPathName(String path) {
		String[] arr = path.split("/");
		return arr[arr.length - 1];
	}

	public static final String getPathNameParent(String path) {
		String[] arr = path.split("/");
		String s = "";
		for (int i = 0; i < arr.length - 1; i++) {
			s += arr[i] + "/";
		}
		return s;
	}
}
