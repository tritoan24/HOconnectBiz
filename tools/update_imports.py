import os
import re

def update_imports_in_file(file_path):
    """Thay đổi tất cả import từ doanhnghiepaap thành clbdoanhnhansg trong một file"""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Thay thế import
    updated_content = re.sub(
        r"import\s+['\"]package:doanhnghiepaap/", 
        "import 'package:clbdoanhnhansg/", 
        content
    )
    
    # Thay thế các import với dấu ngoặc kép
    updated_content = re.sub(
        r'import\s+["\'']package:doanhnghiepaap/', 
        'import "package:clbdoanhnhansg/', 
        updated_content
    )
    
    if content != updated_content:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(updated_content)
        return True
    
    return False

def find_dart_files(directory):
    """Tìm tất cả các file Dart trong thư mục"""
    dart_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def main():
    # Đường dẫn thư mục lib
    lib_directory = os.path.join(os.getcwd(), 'lib')
    
    # Tìm tất cả file Dart
    dart_files = find_dart_files(lib_directory)
    
    # Số lượng file được thay đổi
    changed_files = 0
    
    # Thay đổi import trong mỗi file
    for file_path in dart_files:
        if update_imports_in_file(file_path):
            changed_files += 1
            rel_path = os.path.relpath(file_path, os.getcwd())
            print(f"Đã cập nhật: {rel_path}")
    
    print(f"\nĐã hoàn thành! Tổng số file được thay đổi: {changed_files}/{len(dart_files)}")

if __name__ == "__main__":
    main() 