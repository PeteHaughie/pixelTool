# P8PNGFileFormat

PICO-8 can save cartridges in two file formats: the .p8 format, and the .p8.png format. The save command will use the format that corresponds to the filename extension.

The .p8.png format is a binary format based on the PNG image format. A .p8.png file is an image that can be viewed in any image viewer (such as a web browser). The image appears as the picture of a game cartridge. PICO-8 generates this image using the most recent screenshot taken when pressing the F7 key while the cart is running. If the first two lines of Lua code are comments (a title and byline), it also puts the text of these comments on the label image.

The cart data is stored using a steganographic process. Each PICO-8 byte is stored as the two least significant bits of each of the four color channels, ordered ARGB (E.g: the A channel stores the 2 most significant bits in the bytes). The image is 160 pixels wide and 205 pixels high, for a possible storage of 32,800 (0x8020) bytes.

## Graphics and sound

Bytes 0x0000-0x42ff are the spritesheet, map, flags, music, and sound effects data. These are copied directly into memory when the cart runs. See ~~Memory~~ for a complete explanation of the order and format of this data.

## Lua code

Bytes 0x4300-0x7fff are the Lua code.

If the first four bytes (0x4300-0x4303) are a null (\x00) followed by pxa, then the code is stored in the new (v0.2.0+) compressed format. (See below)

If the first four bytes (0x4300-0x4303) are :c: followed by a null (\x00), then the code is stored in the old (pre-v0.2.0) compressed format. (See below)

In all other cases, the code is stored as plaintext (ASCII), up to the first null byte (if any).

## New Compressed Format

- The first four bytes (0x4300-0x4303) are \x00pxa.
- The next two bytes (0x4304-0x4305) are the length of the decompressed code, stored MSB first.
- The next two bytes (0x4306-0x4307) are the length of the compressed data + 8 for this 8-byte header, stored MSB first.
- The remainder (0x4308-0x7fff) is the compressed data.

The decompression algorithm maintains a "[move-to-front](https://en.wikipedia.org/wiki/Move-to-front_transform)" mapping of the 256 possible bytes. Initially, each of the 256 possible bytes maps to itself.

The decompression algorithm processes the compressed data bit by bit - going from LSB to MSB of each byte - until the expected length of decompressed characters has been emitted.

Each group of bits starts with a single header bit, specifying the group's type.

- If that header bit is 1, an index is read via the following:

```lua
-- read a unary value
unary = 0
while read_bit() == 1 do unary += 1 end

-- unary_mask ensures that each value of 'unary' allows the encoding of different indices
unary_mask = ((1 << unary) - 1)
index = read_bits(4 + unary) + (unary_mask << 4)
```

This index is used as a 0-based index to the move-to-front mapping. The byte mapped by the index is written to the output stream.

This byte is then moved to the front of the move-to-front mapping. (E.g. if the mapping is 0,1,2,3,4,5,... and the index is 3, the mapping is updated to be 3,0,1,2,4,5,...)

- Otherwise, if the header bit is 0, an offset and a length are read via the following:

```lua
-- read the offset
offset_bits = read_bit() ? (read_bit() ? 5 : 10) : 15
offset = read_bits(offset_bits) + 1

-- read the length
length = 3
repeat
  part = read_bits(3)
  length += part
until part != 7
```

Then we go back "offset" characters in the output stream, and copy "length" characters to the end of the output stream. "length" may be larger than "offset", in which case we effectively repeat a pattern of "offset" characters.

As a special exception, if offset_bits == 10 and offset == 1 (aka, the minimal offset is encoded with more bits than necessary), this is interpreted as a start of an uncompressed block.

When this happens, right after the offset is read, 8-bit characters are continually read as groups of 8 bits each (without any byte alignment), until a null is found (0x00).

## Old Compressed Format

- The first four bytes (0x4300-0x4303) are :c:\x00.
- The next two bytes (0x4304-0x4305) are the length of the decompressed code, stored MSB first.
- The next two bytes (0x4306-0x4307) are always zero.
- The remainder (0x4308-0x7fff) is the compressed data.

The decompression algorithm processes the compressed data one byte at a time, and performs an action based on the value, until the expected length of decompressed characters has been emitted:

- 0x00: Copy the next byte directly to the output stream.
- 0x01-0x3b: Emit a character from a lookup table: newline, space, 0123456789abcdefghijklmnopqrstuvwxyz!#%(){}[]<>+=/*:;.,~_
- 0x3c-0xff: Calculate an offset and length from this byte and the next byte, then copy those bytes from what has already been emitted. In other words, go back "offset" characters in the output stream, copy "length" characters, then paste them to the end of the output stream. Offset and length are calculated as:

```lua
offset = (current_byte - 0x3c) * 16 + (next_byte & 0xf)
length = (next_byte >> 4) + 2
```

Note that length can not be greater than offset. (Unlike typical length-offset encodings)

## Version ID
Byte 0x8000 encodes a version ID. This appears to have changed over multiple versions of PICO-8, but the file format has not changed.

Bytes 0x8001-0x8003 encode the "real" PICO-8 version, e.g. v0.2.4 is encoded as 0x00, 0x02, 0x04. (Appeared partway through version ID 8, was all-0 before) (Before v0.2.0, byte 0x8003 was just an incrementing integer and didn't reflect the real version)

Byte 0x8004 encodes a platform ID, e.g. 0x77 ('w') for Windows, 0x6c ('l') for Linux, 0x78 ('x') for Mac(?), 0x45 ('E') for Education version. (Appeared partway through version ID 8, was all-0 before)

Byte 0x8005 encodes the letter suffix of the "real" PICO-8 version, e.g. v0.2.4c gives 0x02. (Appeared in v0.2.1b, was 0 before)

Bytes 0x8006-0x8019 are either all 0, or - starting from version ID 2x - a SHA1 hash of the first 0x8000 bytes in the cart. If this is a non-0 hash, it is checked and the cartridge is treated as corrupted if wrong.

Bytes 0x801a-0x801f are currently all 0.

## References

- For official C code released by Lexaloffle that supports the compression format: [https://github.com/dansanderson/lexaloffle](https://github.com/dansanderson/lexaloffle)
- For a Python library that can read files in this format, see [Picotool](https://pico-8.fandom.com/wiki/Picotool) ([GitHub](https://github.com/dansanderson/picotool)).
- For a Python library that can convert to/from this format, see [Shrinko8](https://pico-8.fandom.com/wiki/Shrinko8) ([GitHub](https://github.com/thisismypassport/shrinko8)).
- Forum post by asterick describing the code compression format: [http://www.lexaloffle.com/bbs/?tid=2400](http://www.lexaloffle.com/bbs/?tid=2400)
- [Lempel–Ziv–Welch compression](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch)