#! /usr/bin/awk -f

BEGIN {
	base_count = 0
	left_count = 0
	right_count = 0
}

function debug(msg)
{
	print "[DEBUG] " msg > "/dev/stderr"
}

function die(msg)
{
	print "[FAILED] " msg > "/dev/stderr"
	exit -1
}

BEGINFILE {
	if (state == "base") {
		state = "left"
	}
	else if (state == "left") {
		state = "right"
	}
	else if (state == "right") {
		die("no more files expected")
		exit -1
	}
	else {
		state = "base"
	}

	input = FILENAME
}

state == "base" { base[base_count++] = $0; next } 
state == "left" { left[left_count++] = $0; next } 
state == "right" { right[right_count++] = $0; next } 

function print_array(a, i, count, prefix)
{
	if (!prefix)
		prefix = "+ "

	while (i < count)
		print prefix a[i++]
}

function find_in_array(a, i, count, needle)
{
	while (i < count) {
		if (a[i] == needle)
			return i

		i += 1
	}

	return -1
}

function merge_2way(left, l, llen, right, r, rlen, in_l, in_r)
{
	while (l < llen && r < rlen) {
		in_l = find_in_array(left, l, llen, right[r])

		if (in_l == l) {
			# assert left[l] == right[r], they equal
			print_array(right, r, r + 1)
			l += 1
			r += 1
		}
		# right[r] is at left[in_l]
		else if (in_l >= 0) {
			print_array(left, l, in_l, "l ")
			l = in_l + 1
			r += 1
		}
		else {
			in_r = find_in_array(right, r, rlen, left[l])

			if (in_r >= 0) {
				print_array(right, r, in_r, "r ")
				l += 1
				r = in_r + 1
			}
			else {
				print_array(right, r, r + 1, "r ")
				r += 1
				print_array(left, l, l + 1, "l ")
				l += 1
			}
		}
	}

	# only one of those will happen
	if (l < llen)
		print_array(left, l, llen, "l ")
	if (r < rlen)
		print_array(right, r, rlen, "r ")
}

function merge_3way(base, b, blen, left, l, llen, right, r, rlen, in_l, in_r)
{
	while (b < blen) {
		in_l = find_in_array(left, l, llen, base[b])
		in_r = find_in_array(right, r, rlen, base[b])

		if (in_l < 0 && in_r < 0) {
			print_array(base, b, b + 1, "b ")
			b += 1
		}
		else if (in_l >= 0 && in_r < 0) {
			print_array(left, l, in_l + 1, "l ")
			print_array(base, b, b + 1, "b ")
			l = in_l + 1
			b += 1
		}
		else if (in_l < 0 && in_r >= 0) {
			print_array(right, r, in_r + 1, "r ")
			print_array(base, b, b + 1, "b ")
			r = in_r + 1
			b += 1
		}
		else {
			merge_2way(left, l, in_l, right, r, in_r)
			print_array(base, b, b + 1, "+ ")
			l = in_l + 1
			r = in_r + 1
			b += 1
		}
	}
}

END {
	if (base_count == 0 && left_count == 0 && right_count == 0)
		exit 0

	if (base_count == 0 && left_count == 0) {
		print_array(right, 0, right_count)
		exit 0
	}

	if (base_count == 0 && right_count == 0) {
		print_array(left, 0, left_count)
		exit 0
	}

	if (base_count == 0) {
		merge_2way(left, 0, left_count, right, 0, right_count)
	}
	else {
		merge_3way(base, 0, base_count, left, 0, left_count, right, 0, right_count)
	}
}
