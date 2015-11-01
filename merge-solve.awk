#! /usr/bin/awk -f

BEGIN {
	b = 0
	l = 0
	r = 0
}

function is_trivial(a, len)
{
	if (len != b)
		return 0

	for (i = 0; i < b; ++i) {
		if (a[i] != base[i])
			return 0
	}

	return 1
}

function solve_conflict()
{
	if (l > 0 && (r == 0 || is_trivial(right, r))) {
		for (i = 0; i < l; ++i)
			print left[i]
	}
	else if (r > 0 && (l == 0 || is_trivial(left, l))) {
		for (i = 0; i < r; ++i)
			print right[i]
	}
	else if (l > 0 && r > 0) {
		print "<<<<<<< LEFT"
		for (i = 0; i < l; ++i)
			print left[i]
		if (b > 0) {
			print "|||||||"
			for (i = 0; i < b; ++i)
				print base[i]
			print "|||||||"
		}
		else {
			print "======="
		}

		for (i = 0; i < r; ++i)
			print right[i]
		print ">>>>>>> RIGHT"
	}

	b = 0
	l = 0
	r = 0
}

/^\+ / {
	solve_conflict()
	sub(/^\+ /, "")
	print
	next
}

/^b / {
	sub(/^b /, "")
	base[b++] = $0
	next
}

/^l / {
	sub(/^l /, "")
	left[l++] = $0
	next
}

/^r / {
	sub(/^r /, "")
	right[r++] = $0
	next
}

END {
	solve_conflict()
}
