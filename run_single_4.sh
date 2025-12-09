sglang_source_path=/data/d00662834/1206/sglang
npu_num=4

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jinja2-cli

testcases=$(cat single_test_case_4)
max_thread_num=3

i=1
log_path=log/$(date "+%Y-%m-%d_%H_%M_%S")
mkdir -p ${log_path}
for test_case in ${testcases}
do
  log=${log_path}/single_npu${npu_num}_$i.log
  > ${log}
  echo "${test_case} begin..." >> ${log}

  nohup ./run_single_base.sh ${sglang_source_path} ${test_case} ${npu_num}>>${log} &

  while true
  do
    threads=$(ps -ef | grep "run_single_base.sh" | grep -v grep | wc -l)
    if ([ ${threads} -lt ${max_thread_num} ]);then
       break
    fi
  done
  
  ((i++))

done

i=1
for test_case in ${testcases}
do
  echo "Run failed: ${test_case}"
  is_failed=$(cat ${log_path}/single_npu${npu_num}_$i.log | grep FAILED)
  if [ -n "${is_failed}" ];then
    mv ${log_path}/single_npu${npu_num}_$i.log  ${log_path}/single_npu${npu_num}_$i.log_failed
  fi
  ((i++))
done
