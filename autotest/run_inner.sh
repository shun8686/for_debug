testcases=`cat testcases`

for tc in ${testcases}
do
  pkill python
  pkill sglang

  tc_name=${tc##*/}
  tc_name=${tc_name%.*}

  echo "${tc}" > log/${tc_name}.log

  python3 -u ${tc}  >> log/${tc_name}.log 2>&1

  echo "Finish test case ${tc}" >> log/${tc_name}.log

done
