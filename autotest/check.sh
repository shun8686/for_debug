testcases=`cat testcase_list`
for tc in ${testcases}
do
  echo "${tc}"
  cat ${tc} | grep "w8a8_int8"
done
