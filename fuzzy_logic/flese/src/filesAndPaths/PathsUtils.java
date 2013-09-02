package filesAndPaths;

import java.io.File;

public class PathsUtils {

	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static String concatPathsStrings(String head, String tail) {
		String result = null;
		if (head.endsWith("/")) {
			if (tail.startsWith("/")) {
				result = head + tail.substring(1, tail.length());
			} else {
				result = head + tail;
			}
		} else {
			if (tail.startsWith("/")) {
				result = head + tail;
			} else {
				result = head + "/" + tail;
			}
		}

		return result;
	}
	
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public static boolean testIfFileExists(String fullPath, boolean launchException) throws PathsMgmtException {
		if (fullPath == null)
			throw new PathsMgmtException("fullPath cannot be null.");
		if ("".equals(fullPath))
			throw new PathsMgmtException("fullPath cannot be empty string.");
		if ("/".equals(fullPath))
			throw new PathsMgmtException("fullPath cannot be the string /.");

		File file = new File(fullPath);
		if (!file.exists()) {
			if (launchException)
				throw new PathsMgmtException("file does not exist. file: " + fullPath);
			return false;
		}
		if (!file.isFile()) {
			if (launchException)
				throw new PathsMgmtException("file is not a file. file: " + fullPath);
			return false;
		}
		if (!file.canRead()) {
			if (launchException)
				throw new PathsMgmtException("file is not readable. file: " + fullPath);
			return false;
		}
		return true;
	}
	
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static boolean testIfFolderExists(String folderName, boolean createFolderIfDoesNotExist) throws PathsMgmtException {
		boolean retVal = false;

		File dir = new File(folderName);
		if (dir.exists()) {
			if (dir.isDirectory() && dir.canRead() && dir.canWrite() && dir.canExecute()) {
				retVal = true;
			}
		} else {
			if (createFolderIfDoesNotExist) {
				try {
					retVal = dir.mkdirs();
				} catch (Exception ex) {
					throw new PathsMgmtException("The folder " + folderName + "can not be created.");
				}
			}
		}
		return retVal;
	}
	
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////

}
