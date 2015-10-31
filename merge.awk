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

input != FILENAME {
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

state == "base" { base[base_count++] = $0 } 
state == "left" { left[left_count++] = $0 } 
state == "right" { right[right_count++] = $0 } 

function left_conflict(name)
{
	if (length(name) > 0)
		print "<<<<<< " name
	else
		print "<<<<<< LEFT"
}

function base_conflict(name)
{
	if (length(name) > 0)
		print "====== " name
	else
		print "====== BASE"
}

function right_conflict(name)
{
	if (length(name) > 0)
		print "====== " name
	else
		print "====== RIGHT"
}

function close_conflict()
{
	print ">>>>>>"
}

function naive_merge3(i)
{
	if (base[i] == left[i] && left[i] == right[i])
		print base[i]
	else if (base[i] == left[i] && left[i] != right[i])
		print right[i]
	else if (base[i] == right[i] && left[i] != right[i])
		print left[i]
	else if (left[i] == right[i] && base[i] != left[i])
		print left[i]
	else {
		left_conflict("")
		print left[i]
		base_conflict("")
		print base[i]
		right_conflict("")
		print right[i]
		close_conflict()
	}
}

function conflict_end(i)
{
	if (i >= left_count && i >= right_count)
		return

	left_conflict("")

	for (j = i; j < left_count; ++j)
		print left[i]

	right_conflict("")

	for (j = i; j < right_count; ++j)
		print right[i]

	close_conflict()
}

END {
	for (i = 0; ; ++i) {
		if (i >= base_count) {
			conflict_end(i)
			break
		}

		naive_merge3(i)
	}
}
