# AIDC Lite

AI Data Compression Lite


# Compressor Block Diagram

<pre>
     +-----------------------------+
     |  +------+                   |
APB  ===| CFG  |                   |
     |  +------+                   |
     |      |                      |
     |  +--------+     +--------+  |
     |  | ENGINE |-----| BUFFER |  |
     |  |        |     | (128B) |  |
     |  +--------+     +--------+  |
     |      ||     \        |      |
     |      ||       \ +--------+  |
     |      ||         |  COMP  |  |
     |      ||         +--------+  |
     +------||---------------------+
           AHB
</pre>


# Decompressor
