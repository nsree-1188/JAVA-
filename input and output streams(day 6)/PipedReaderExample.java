import java.io.*;

class WriterThread extends Thread {
    private final PipedWriter writer;

    public WriterThread(PipedWriter writer) {
        this.writer = writer;
    }

    @Override
    public void run() {
        try {
            writer.write("Hello from WriterThread!");
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

class ReaderThread extends Thread {
    private final PipedReaderEx reader;

    public ReaderThread(PipedReaderEx reader) {
        this.reader = reader;
    }

    @Override
    public void run() {
        try {
            int data;
            while ((data = reader.read()) != -1) {
                System.out.print((char) data);
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

public class PipedReaderExample {
    public static void main(String[] args) {
        try {
            PipedWriter writer = new PipedWriter();
            PipedReaderEx reader = new PipedReaderEx(writer);

            WriterThread writerThread = new WriterThread(writer);
            ReaderThread readerThread = new ReaderThread(reader);

            writerThread.start();
            readerThread.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
