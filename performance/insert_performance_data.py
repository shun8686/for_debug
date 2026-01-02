import re
import pymysql
import argparse
import os
from datetime import datetime

# 日志文件解析函数
def parse_benchmark_log(log_path):
    if not os.path.exists(log_path):
        raise FileNotFoundError(f"Log file not found: {log_path}")
    
    with open(log_path, 'r') as f:
        content = f.read()
    
    # 定义要提取的指标和对应的正则表达式模式
    metrics_patterns = {
        'backend': r'Backend:\s+(\w+)',
        'traffic_request_rate': r'Traffic request rate:\s+(\d+\.\d+)',
        'max_request_concurrency': r'Max request concurrency:\s+(\d+)',
        'successful_requests': r'Successful requests:\s+(\d+)',
        'benchmark_duration': r'Benchmark duration \(s\):\s+(\d+\.\d+)',
        'total_input_tokens': r'Total input tokens:\s+(\d+)',
        'total_input_text_tokens': r'Total input text tokens:\s+(\d+)',
        'total_input_vision_tokens': r'Total input vision tokens:\s+(\d+)',
        'total_generated_tokens': r'Total generated tokens:\s+(\d+)',
        'total_generated_tokens_retokenized': r'Total generated tokens \(retokenized\):\s+(\d+)',
        'request_throughput': r'Request throughput \(req/s\):\s+(\d+\.\d+)',
        'input_token_throughput': r'Input token throughput \(tok/s\):\s+(\d+\.\d+)',
        'output_token_throughput': r'Output token throughput \(tok/s\):\s+(\d+\.\d+)',
        'peak_output_token_throughput': r'Peak output token throughput \(tok/s\):\s+(\d+\.\d+)',
        'total_token_throughput': r'Total token throughput \(tok/s\):\s+(\d+\.\d+)',
        'concurrency': r'Concurrency:\s+(\d+\.\d+)',
        'accept_length': r'Accept length:\s+(\d+\.\d+)',
        'mean_e2e_latency_ms': r'Mean E2E Latency \(ms\):\s+(\d+\.\d+)',
        'median_e2e_latency_ms': r'Median E2E Latency \(ms\):\s+(\d+\.\d+)',
        'mean_ttft_ms': r'Mean TTFT \(ms\):\s+(\d+\.\d+)',
        'median_ttft_ms': r'Median TTFT \(ms\):\s+(\d+\.\d+)',
        'p99_ttft_ms': r'P99 TTFT \(ms\):\s+(\d+\.\d+)',
        'mean_tpot_ms': r'Mean TPOT \(ms\):\s+(\d+\.\d+)',
        'median_tpot_ms': r'Median TPOT \(ms\):\s+(\d+\.\d+)',
        'p99_tpot_ms': r'P99 TPOT \(ms\):\s+(\d+\.\d+)',
        'mean_itl_ms': r'Mean ITL \(ms\):\s+(\d+\.\d+)',
        'median_itl_ms': r'Median ITL \(ms\):\s+(\d+\.\d+)',
        'p95_itl_ms': r'P95 ITL \(ms\):\s+(\d+\.\d+)',
        'p99_itl_ms': r'P99 ITL \(ms\):\s+(\d+\.\d+)',
        'max_itl_ms': r'Max ITL \(ms\):\s+(\d+\.\d+)'
    }
    
    # 提取指标值
    metrics = {}
    for key, pattern in metrics_patterns.items():
        match = re.search(pattern, content)
        if match:
            metrics[key] = match.group(1)
        else:
            metrics[key] = None
    
    return metrics

# 数据库插入函数
def insert_to_mysql(metrics, log_path, db_config):
    # 提取日志文件的上层目录名称作为test_time
    log_dir = os.path.dirname(log_path)
    date_str = os.path.basename(log_dir)
    
    # 将目录名称转换为DATETIME格式（假设目录名称为YYYYMMDD格式）
    try:
        # 解析日期字符串为datetime对象
        date_obj = datetime.strptime(date_str, "%Y%m%d")
        # 格式化为MySQL DATETIME格式
        test_time = date_obj.strftime("%Y-%m-%d %H:%M:%S")
    except ValueError:
        # 如果目录名称不是标准日期格式，使用当前日期时间
        print(f"目录名称 '{date_str}' 不是标准的YYYYMMDD格式，使用当前日期时间")
        test_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # 提取日志文件的名称（不含扩展名）作为test_case
    file_name = os.path.basename(log_path)
    test_case = os.path.splitext(file_name)[0]
    
    # 连接到MySQL数据库
    connection = pymysql.connect(
        host=db_config['host'],
        user=db_config['user'],
        password=db_config['password'],
        database=db_config['database'],
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    
    try:
        with connection.cursor() as cursor:
            # 创建表（如果不存在）- 将test_time改为DATETIME类型
            create_table_sql = """
            CREATE TABLE IF NOT EXISTS performance_metrics (
                id INT AUTO_INCREMENT PRIMARY KEY,
                test_case VARCHAR(100),
                test_time DATETIME,
                backend VARCHAR(50),
                traffic_request_rate FLOAT,
                max_request_concurrency INT,
                successful_requests INT,
                benchmark_duration FLOAT,
                total_input_tokens BIGINT,
                total_input_text_tokens BIGINT,
                total_input_vision_tokens BIGINT,
                total_generated_tokens BIGINT,
                total_generated_tokens_retokenized BIGINT,
                request_throughput FLOAT,
                input_token_throughput FLOAT,
                output_token_throughput FLOAT,
                peak_output_token_throughput FLOAT,
                total_token_throughput FLOAT,
                concurrency FLOAT,
                accept_length FLOAT,
                mean_e2e_latency_ms FLOAT,
                median_e2e_latency_ms FLOAT,
                mean_ttft_ms FLOAT,
                median_ttft_ms FLOAT,
                p99_ttft_ms FLOAT,
                mean_tpot_ms FLOAT,
                median_tpot_ms FLOAT,
                p99_tpot_ms FLOAT,
                mean_itl_ms FLOAT,
                median_itl_ms FLOAT,
                p95_itl_ms FLOAT,
                p99_itl_ms FLOAT,
                max_itl_ms FLOAT,
                log_file_path VARCHAR(255),
                UNIQUE KEY idx_test_time_test_case (test_case, test_time)
            )
            """
            cursor.execute(create_table_sql)
            
            # 插入数据 - 包含test_time和test_case字段，如果唯一键存在则更新
            insert_sql = """
            INSERT INTO performance_metrics (
                test_case, test_time, backend, traffic_request_rate, max_request_concurrency, successful_requests,
                benchmark_duration, total_input_tokens, total_input_text_tokens, total_input_vision_tokens,
                total_generated_tokens, total_generated_tokens_retokenized, request_throughput,
                input_token_throughput, output_token_throughput, peak_output_token_throughput,
                total_token_throughput, concurrency, accept_length, mean_e2e_latency_ms,
                median_e2e_latency_ms, mean_ttft_ms, median_ttft_ms, p99_ttft_ms, mean_tpot_ms,
                median_tpot_ms, p99_tpot_ms, mean_itl_ms, median_itl_ms, p95_itl_ms,
                p99_itl_ms, max_itl_ms, log_file_path
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            ) ON DUPLICATE KEY UPDATE
                backend = VALUES(backend),
                traffic_request_rate = VALUES(traffic_request_rate),
                max_request_concurrency = VALUES(max_request_concurrency),
                successful_requests = VALUES(successful_requests),
                benchmark_duration = VALUES(benchmark_duration),
                total_input_tokens = VALUES(total_input_tokens),
                total_input_text_tokens = VALUES(total_input_text_tokens),
                total_input_vision_tokens = VALUES(total_input_vision_tokens),
                total_generated_tokens = VALUES(total_generated_tokens),
                total_generated_tokens_retokenized = VALUES(total_generated_tokens_retokenized),
                request_throughput = VALUES(request_throughput),
                input_token_throughput = VALUES(input_token_throughput),
                output_token_throughput = VALUES(output_token_throughput),
                peak_output_token_throughput = VALUES(peak_output_token_throughput),
                total_token_throughput = VALUES(total_token_throughput),
                concurrency = VALUES(concurrency),
                accept_length = VALUES(accept_length),
                mean_e2e_latency_ms = VALUES(mean_e2e_latency_ms),
                median_e2e_latency_ms = VALUES(median_e2e_latency_ms),
                mean_ttft_ms = VALUES(mean_ttft_ms),
                median_ttft_ms = VALUES(median_ttft_ms),
                p99_ttft_ms = VALUES(p99_ttft_ms),
                mean_tpot_ms = VALUES(mean_tpot_ms),
                median_tpot_ms = VALUES(median_tpot_ms),
                p99_tpot_ms = VALUES(p99_tpot_ms),
                mean_itl_ms = VALUES(mean_itl_ms),
                median_itl_ms = VALUES(median_itl_ms),
                p95_itl_ms = VALUES(p95_itl_ms),
                p99_itl_ms = VALUES(p99_itl_ms),
                max_itl_ms = VALUES(max_itl_ms),
                log_file_path = VALUES(log_file_path)
            """
            
            # 执行插入或更新操作
            cursor.execute(insert_sql, (
                test_case, test_time, metrics['backend'], metrics['traffic_request_rate'], metrics['max_request_concurrency'],
                metrics['successful_requests'], metrics['benchmark_duration'], metrics['total_input_tokens'],
                metrics['total_input_text_tokens'], metrics['total_input_vision_tokens'], metrics['total_generated_tokens'],
                metrics['total_generated_tokens_retokenized'], metrics['request_throughput'], metrics['input_token_throughput'],
                metrics['output_token_throughput'], metrics['peak_output_token_throughput'], metrics['total_token_throughput'],
                metrics['concurrency'], metrics['accept_length'], metrics['mean_e2e_latency_ms'],
                metrics['median_e2e_latency_ms'], metrics['mean_ttft_ms'], metrics['median_ttft_ms'],
                metrics['p99_ttft_ms'], metrics['mean_tpot_ms'], metrics['median_tpot_ms'],
                metrics['p99_tpot_ms'], metrics['mean_itl_ms'], metrics['median_itl_ms'],
                metrics['p95_itl_ms'], metrics['p99_itl_ms'], metrics['max_itl_ms'], log_path
            ))
        
        # 提交事务
        connection.commit()
        # 获取受影响的行数，判断是插入还是更新
        affected_rows = cursor.rowcount
        if affected_rows == 1:
            print("数据插入成功！")
        elif affected_rows == 2:
            print("数据更新成功！")
        else:
            print(f"数据操作完成，受影响行数: {affected_rows}")
        
    except Exception as e:
        print(f"插入数据时出错: {e}")
    finally:
        connection.close()

# 批量处理目录中的日志文件
def process_directory(log_dir, db_config):
    """
    处理目录中的所有日志文件
    
    Args:
        log_dir: 日志文件所在目录
        db_config: 数据库配置
    """
    if not os.path.exists(log_dir):
        print(f"目录不存在: {log_dir}")
        return
    
    # 查找目录中所有.txt文件（包括子目录）
    txt_files = []
    for root, dirs, files in os.walk(log_dir):
        for file in files:
            if file.endswith('.txt'):
                txt_files.append(os.path.join(root, file))
    
    if not txt_files:
        print(f"在目录 {log_dir} 中未找到.txt文件")
        return
    
    print(f"在目录 {log_dir} 中找到 {len(txt_files)} 个日志文件")
    
    # 处理每个日志文件
    for file_path in txt_files:
        try:
            print(f"\n正在处理文件: {file_path}")
            # 解析日志文件
            metrics = parse_benchmark_log(file_path)
            
            # 插入到数据库
            insert_to_mysql(metrics, file_path, db_config)
            print(f"文件 {file_path} 处理完成")
        except Exception as e:
            print(f"处理文件 {file_path} 时出错: {e}")
            continue
    
    print(f"\n所有 {len(txt_files)} 个文件处理完成")

# 主函数
def main():
    parser = argparse.ArgumentParser(description='从目录提取性能数据并插入到MySQL数据库')
    parser.add_argument('--log_dir', type=str, default='./metrics', help='日志文件所在目录')
    parser.add_argument('--host', type=str, default='localhost', help='MySQL主机地址')
    parser.add_argument('--user', type=str, default='root', help='MySQL用户名')
    parser.add_argument('--password', type=str, required=True, help='MySQL密码')
    parser.add_argument('--database', type=str, default='performance_db', help='MySQL数据库名')
    
    args = parser.parse_args()
    
    # 数据库配置
    db_config = {
        'host': args.host,
        'user': args.user,
        'password': args.password,
        'database': args.database
    }
    
    # 处理目录
    process_directory(args.log_dir, db_config)

if __name__ == '__main__':
    main()