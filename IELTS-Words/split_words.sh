#!/bin/bash

# 确保words.txt文件存在
if [ ! -f "words.txt" ]; then
    echo "Error: words.txt file not found!"
    exit 1
fi

# 获取文件总行数（去除可能的空格）
total_lines=$(wc -l < words.txt | tr -d ' ')
echo "Total lines in words.txt: $total_lines"

# 计算需要生成的文件数
file_count=$(( (total_lines + 29) / 30 ))
echo "Will generate $file_count files"

# 直接使用循环处理每个文件，使用序号命名
for ((i=0; i<file_count; i++)); do
    # 计算文件序号（从1开始）
    file_number=$((i + 1))
    
    # 计算起始行和结束行
    start=$((i * 30 + 1))
    end=$((start + 29))
    
    # 确保结束行不超过总行数
    if [ $end -gt $total_lines ]; then
        end=$total_lines
    fi
    
    # 使用序号命名文件
    output_file="${file_number}-words.txt"
    
    # 使用sed提取对应行范围，创建新文件
    sed -n "${start},${end}p" words.txt > "$output_file"
    
    echo "Created file: $output_file (lines $start-$end)"
done

# 验证所有行都被处理
last_file_number=$file_count
last_file="${last_file_number}-words.txt"
last_start=$(( (file_count - 1) * 30 + 1 ))
last_end=$(( last_start + 29 > total_lines ? total_lines : last_start + 29 ))

echo "Last file: $last_file (lines $last_start-$last_end)"

if [ $last_end -eq $total_lines ]; then
    echo "All $total_lines lines have been processed successfully!"
else
    echo "Warning: Only processed up to line $last_end of $total_lines total lines."
fi

echo "File splitting completed!"
