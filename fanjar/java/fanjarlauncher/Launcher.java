package fanjarlauncher;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.Manifest;

/**
 * This is a Java launcher for Fantom apps packaged into a standalone Java jar.
 * This launcher is package into a jar as the "main" along with Fantom code/runtime.
 * - When the jar is run, it copies the Fantom runtime into a temp dir
 * - Then the launcher starts a given Fantom program using that runtime.
 *
 * TODO: Check the runtime version and only re-extract it of not up to date ?
 * @author thibautc
 */
public class Launcher
{

	private static final String RT_FOLDER_NAME = "fantom-rt";
	private static final boolean IS_WIN = System.getProperty("os.name").toLowerCase().indexOf("windows") != -1;
	public static File runtimeDir;
	volatile boolean shutdownStreams = false;

	/**
	 * Run the given (main) Fantom program usng the runtime we setup
	 * @param main
	 * @throws Exception
	 */
	public void executeFantom(String main) throws Exception
	{
		String fanExe = runtimeDir.getAbsoluteFile() + File.separator + "fantom" + File.separator + "bin" + File.separator + "fan";
		new File(fanExe).setExecutable(true);
		System.out.println("Running: " + fanExe + " " + main);
		Process ps = Runtime.getRuntime().exec(
			new String[]
			{
				fanExe, main
			});
		// We need to rread the stream to avoid the process hanging on full buffers.
		new StreamForwarder(ps.getInputStream(), System.out).start();
		new StreamForwarder(ps.getErrorStream(), System.err).start();
		ps.waitFor();
		shutdownStreams=true;
	}

	/**
	 * Extract the Fantom 'runtime' from the jar and set it up in a user dir
	 * Return the name of the "main"
	 */
	public String setupFantomEnv(JarFile jf) throws Exception
	{
		byte[] buffer = new byte[10000];
		Manifest mf = jf.getManifest();
		String main = mf.getMainAttributes().getValue("Fantom-Main");
		Enumeration<JarEntry> entries = jf.entries();
		runtimeDir.mkdirs();
		while (entries.hasMoreElements())
		{
			JarEntry entry = entries.nextElement();
			if (entry.getName().startsWith("fantom"))
			{
				File f = new File(runtimeDir.getAbsolutePath() + File.separator + entry.getName());
				//System.out.println("Extracting " + f.getAbsolutePath());
				f.getParentFile().mkdirs();
				if (!entry.isDirectory())
				{
					f.createNewFile();
					FileOutputStream fos = new FileOutputStream(f);
					InputStream is = jf.getInputStream(entry);
					//TODO try/catch/finally
					int read = 0;
					do
					{
						read = is.read(buffer);
						if (read > 0)
						{
							fos.write(buffer, 0, read);
						}
					} while (read > 0);
					is.close();
					fos.close();
				}
			}
		}
		return main;
	}

	/**
	 * Find the jar name, this launcher is a part of.
	 * Since we are run using "-jar", the first and only thing in the cp is this jar itself
	 * TODO: -> is that always true ?
	 * @return
	 */
	public String getJarName()
	{
		String jar = null;
		String cp = System.getProperty("java.class.path");
		String[] items = cp.split(File.pathSeparator);
		if (items.length > 0)
		{
			int idx = items[0].indexOf(File.separator);
			if (idx > 0)
			{
				jar = items[0].substring(idx);
			} else
			{
				jar = items[0];
			}
		}

		return jar;
	}

	/**
	 * 
	 */
	public Launcher()
	{
		// Figure OS specific folder we are going to extract the runtime to (within user home)
		String userHome = System.getProperty("user.home");
		String rtDir = userHome + File.separator + (IS_WIN ? "" : ".") + RT_FOLDER_NAME + File.separator;
		runtimeDir = new File(rtDir);

		String main = null;
		String jar = getJarName();
		if (jar == null)
		{
			System.out.println("Could not resolve JarFile in classpath.");
			System.exit(-1);
		}
		JarFile jf = null;
		try
		{
			jf = new JarFile(jar);
			if (jf == null)
			{
				System.out.println("Could not read content of jar: " + jar);
				System.exit(-1);
			}
			// Extract Fantom runtime to user dir
			main = setupFantomEnv(jf);
		} catch (Exception e)
		{
			e.printStackTrace();
			System.exit(-1);
		} finally
		{
			try
			{
				if (jf != null)
				{
					// make sure we close the file
					jf.close();
				}
			} catch (IOException ie)
			{
			}
		}
		// OK, the runtime was extracted, now use it to run the Fantom program
		if (main != null)
		{
			try
			{
				executeFantom(main);
			} catch (Exception e)
			{
				e.printStackTrace();
			}
		}
	}

	public static void main(String[] args)
	{
		new Launcher();
	}

	@Override
	protected void finalize() throws Throwable
	{
		// Try to shutdown the stream threads properly if jvm is killed
		shutdownStreams = true;
		super.finalize();
	}

	/**
	 * 'Pipe' insputstream data into outputstream
	 */
	private class StreamForwarder extends Thread implements Runnable
	{
		InputStream is;
		OutputStream out;
		byte[] buffer = new byte[1000];

		StreamForwarder(InputStream is, OutputStream out)
		{
			this.is = is;
			this.out=out;
		}

		public void shutdown()
		{
			shutdownStreams=true;
		}

		@Override
		public void run()
		{
			try
			{
				while (! shutdownStreams)
				{
					int read = is.read(buffer);
					if(read>0)
						out.write(buffer, 0, read);
					// Don't hog the cpu completely
					sleep(50);
				}
			} catch (Exception e)
			{
				System.out.println("Problem reading stream "+e);
				e.printStackTrace();
			}
			finally
			{
				try{is.close();}catch(IOException ie){}
			}
		}
	}
}
