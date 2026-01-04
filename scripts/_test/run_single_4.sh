sglang_source_path=/data/d00662834/1206/sglang
npu_num=4

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jinja2-cli

testcases=$(cat single_test_case_4)
i=1
for test_case in ${testcases}
do
  log=log/log_${npu_num}_$i.txt
  echo "${log}"
  > ${log}

  nohup ./run_single_base.sh ${sglang_source_path} ${test_case} ${npu_num}>>${log} &

  while true
  do
    threads=$(ps -ef | grep "run_single_base.sh" | grep -v grep | wc -l)
    if ([ ${threads} -le 3 ]);then
       break
    fi
  done
  
  ((i++))

done
