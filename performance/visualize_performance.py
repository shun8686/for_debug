import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.graph_objs as go
import pandas as pd
import json
import os

# 读取性能测试数据
def load_performance_data(log_file="./bench_log.txt"):
    if not os.path.exists(log_file):
        return pd.DataFrame()
    
    # 假设数据格式为JSON或从日志文件提取
    # 这里使用示例数据结构
    data = {
        'test_id': [1, 2, 3, 4, 5],
        'concurrency': [1, 2, 4, 8, 16],
        'ttft': [1.2, 1.5, 1.8, 2.2, 2.8],
        'tpot': [0.05, 0.052, 0.055, 0.06, 0.07],
        'tps': [20, 38, 72, 120, 160]
    }
    return pd.DataFrame(data)

# 初始化Dash应用
app = dash.Dash(__name__, title="大模型性能测试仪表盘")

# 应用布局
app.layout = html.Div([
    html.H1("大模型性能测试数据展示", style={'textAlign': 'center', 'marginBottom': 30}),
    
    # 选择测试数据文件
    html.Div([
        dcc.Input(id='log-file-input', type='text', value='./bench_log.txt', 
                  style={'width': '300px', 'marginRight': '10px'}),
        html.Button('加载数据', id='load-button', n_clicks=0)
    ], style={'textAlign': 'center', 'marginBottom': 20}),
    
    # 性能指标图表
    html.Div([
        # TTFT vs 并发数
        html.Div([
            dcc.Graph(id='ttft-graph', figure=go.Figure())
        ], style={'width': '50%', 'display': 'inline-block'}),
        
        # TPOT vs 并发数
        html.Div([
            dcc.Graph(id='tpot-graph', figure=go.Figure())
        ], style={'width': '50%', 'display': 'inline-block'})
    ]),
    
    # TPS vs 并发数
    html.Div([
        dcc.Graph(id='tps-graph', figure=go.Figure())
    ], style={'marginTop': 20}),
    
    # 实时数据更新
    dcc.Interval(
        id='interval-component',
        interval=5*1000,  # 5秒更新一次
        n_intervals=0
    )
])

# 回调函数 - 加载和更新数据
@app.callback(
    [Output('ttft-graph', 'figure'),
     Output('tpot-graph', 'figure'),
     Output('tps-graph', 'figure')],
    [Input('load-button', 'n_clicks'),
     Input('interval-component', 'n_intervals'),
     Input('log-file-input', 'value')]
)
def update_graphs(n_clicks, n_intervals, log_file):
    df = load_performance_data(log_file)
    
    if df.empty:
        return [go.Figure(), go.Figure(), go.Figure()]
    
    # TTFT图表
    ttft_fig = go.Figure(
        data=[go.Scatter(x=df['concurrency'], y=df['ttft'], mode='lines+markers', name='TTFT')],
        layout=go.Layout(
            title='首Token生成时间 (TTFT) vs 并发数',
            xaxis_title='并发数',
            yaxis_title='TTFT (秒)',
            hovermode='closest'
        )
    )
    
    # TPOT图表
    tpot_fig = go.Figure(
        data=[go.Scatter(x=df['concurrency'], y=df['tpot'], mode='lines+markers', name='TPOT')],
        layout=go.Layout(
            title='每个输出Token时间 (TPOT) vs 并发数',
            xaxis_title='并发数',
            yaxis_title='TPOT (秒)',
            hovermode='closest'
        )
    )
    
    # TPS图表
    tps_fig = go.Figure(
        data=[go.Scatter(x=df['concurrency'], y=df['tps'], mode='lines+markers', name='TPS')],
        layout=go.Layout(
            title='吞吐量 (TPS) vs 并发数',
            xaxis_title='并发数',
            yaxis_title='TPS (tokens/sec)',
            hovermode='closest'
        )
    )
    
    return ttft_fig, tpot_fig, tps_fig

if __name__ == '__main__':
    app.run(debug=True, port=8050)