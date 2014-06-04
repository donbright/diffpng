#!/bin/bash -eux

# Script to run pdiff against a set of image file pairs, and check that the
# PASS or FAIL status is as expected.

#------------------------------------------------------------------------------
# Image files and expected diffpng PASS/FAIL status.  Line format is
# (PASS|FAIL) image1.png image2.png
#
# Edit the following lines to add additional tests.
all_tests () {
cat <<EOF
FAIL Bug1102605_ref.png Bug1102605.png
PASS Bug1471457_ref.png Bug1471457.png
PASS cam_mb_ref.png cam_mb.png
FAIL fish2.png fish1.png
PASS square.png square_scaled.png
FAIL Aqsis_vase.png Aqsis_vase_ref.png
PASS ossphere_color.png ossphere_color2.png
PASS ossphere_mono.png ossphere_mono2.png
FAIL ossphere_color.png ossphere_mono.png
FAIL ossphere_color2.png ossphere_mono.png
FAIL ossphere_color.png ossphere_mono2.png
FAIL ossphere_color2.png ossphere_mono2.png
EOF
}

# Change to test directory
script_directory=$(dirname "$0")
cd "$script_directory"

if [ -f '../build/diffpng' ]
then
	pdiff=../build/diffpng
elif [ -f '../diffpng' ]
then
	pdiff=../diffpng
elif [ -f '../bin/diffpng' ]
then
	pdiff=../bin/diffpng
else
	echo 'diffpng must be built and exist in the repository root or the "build" directory'
	exit 1
fi

#------------------------------------------------------------------------------

total_tests=0
num_tests_failed=0

# Run all tests.
while read expectedResult image1 image2 ; do
	if $pdiff --verbose --scale "$image1" "$image2" 2>&1 | grep -q "^$expectedResult" ; then
		total_tests=$((total_tests+1))
	else
		num_tests_failed=$((num_tests_failed+1))
		echo "Regression failure: expected $expectedResult for \"$pdiff $image1 $image2\"" >&2
	fi
done <<EOF
$(all_tests)
EOF
# (the above with the EOF's is a stupid bash trick to stop while from running
# in a subshell)

# Give some diagnostics:
if [[ $num_tests_failed == 0 ]] ; then
	echo "*** all $total_tests tests passed"
else
	echo "*** $num_tests_failed failed tests of $total_tests"
	exit $num_tests_failed
fi

# Run additional tests.
$pdiff 2>&1 | grep -i openmp
rm -f diff.png
$pdiff --output diff.png --verbose fish[12].png 2>&1 | grep -q 'FAIL'
ls diff.png
rm -f diff.png

head fish1.png > fake.png
$pdiff --verbose fish1.png fake.png 2>&1 | grep -q 'Failed to load'
rm -f fake.png

mkdir -p unwritable.png
$pdiff --output unwritable.png --verbose fish[12].png 2>&1 | grep -q 'Failed to save'
rmdir unwritable.png

$pdiff fish[12].png --output foo 2>&1 | grep -q 'unknown filetype'
$pdiff --verbose fish1.png 2>&1 | grep -q 'Not enough'
$pdiff --downsample -3 fish1.png Aqsis_vase.png 2>&1 | grep -q 'Invalid'
$pdiff --threshold -3 fish1.png Aqsis_vase.png 2>&1 | grep -q 'Invalid'
$pdiff cam_mb_ref.png cam_mb.png --fake-option
$pdiff --verbose --scale fish1.png Aqsis_vase.png 2>&1 | grep -q 'FAIL'
$pdiff --downsample 2 fish1.png Aqsis_vase.png 2>&1 | grep -q 'FAIL'
$pdiff  /dev/null /dev/null 2>&1 | grep -q 'Unknown filetype'
$pdiff --verbose --sum-errors fish[12].png 2>&1 | grep -q 'sum'
$pdiff --colorfactor .5 -threshold 1000 --gamma 3 --luminance 90 cam_mb_ref.png cam_mb.png
$pdiff --verbose -downsample 30 -scale --luminanceonly --fov 80 cam_mb_ref.png cam_mb.png
$pdiff --fov wrong fish1.png fish1.png 2>&1 | grep -q 'Invalid argument'

echo -e '\x1b[01;32mOK\x1b[0m'
