/*
 * REORDER FROM LARGEST TO SMALLEST TO REDUCE INITIAL SLOP !
 *
 * LARGEST                      ->                      SMALLEST
 * +-----------------------+-------------------+---------------+
 * | Temperature    0 - 63 | NTU        0 - 31 | PH     0 - 15 |
 * +-----------------------+-------------------+---------------|
 * | 1 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | <-> 40;20;14
 * +-----------------------+---------------+-------------------+
 * | 0   1   2   3   4   5   6   7   8   9   0   1   2   3   4 | -> 15 bits
 * +-----------------------+---------------+-------------------+
 * |           a           |         b         |       c       |
 * +-----------------------+---------------+-------------------+
 * |              1              |              2              | -> 02 bytes
 * +-----------------------------------------------------------+
 *
 * 0 <= a <= 40 < 41
 * 0 <= b <= 14 < 15
 * 0 <= c <= 20 < 21
 * 
 * PACK:
 * o = c
 * o *= 21
 * o += b
 * o *= 41	
 * o += a
 *
 * UNPACK:
 * a = o % 41
 * o /= 41
 * b = o % 21
 * o /= 21
 * c = o
 *
 * a=40,b=20,c=14
 *
 * pack(a, b, c) = 12914
 * +-------------------------------------------------------+
 * | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 1 | 0 | -> 14 (!) bits
 * +-------------------------------------------------------+ -> 12.5% decrease in size
 *
 * a = 12914 % 41 = 40
 * o /= 41
 * b = 314 % 21 = 20
 * o /= 21
 * c = 14
 */
unsigned short pack(
	unsigned short temp,
	unsigned short ntu,
	unsigned short ph
) {
	unsigned short o = ph;
	o *= 21;
	o += ntu;
	o *= 41;
	o += temp;
	return o;
}

void unpack(
	unsigned short o,
	unsigned short *temp,
	unsigned short *ntu,
	unsigned short *ph
) {
	*temp = o % 41;
	o /= 41;
	*ntu = o % 21;
	o /= 21;
	*ph = o;
}