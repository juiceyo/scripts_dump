import re
import os

def parse_time_to_seconds(time_str):
    """Convert time string (MM:SS) to total seconds"""
    minutes, seconds = map(int, time_str.split(':'))
    return minutes * 60 + seconds

def seconds_to_readable(total_seconds):
    """Convert total seconds to readable format (HH:MM:SS)"""
    hours = total_seconds // 3600
    minutes = (total_seconds % 3600) // 60
    seconds = total_seconds % 60
    
    if hours > 0:
        return f"{hours}:{minutes:02d}:{seconds:02d}"
    else:
        return f"{minutes}:{seconds:02d}"

def calculate_course_time(file_path):
    """Calculate total course time from the input file"""
    total_seconds = 0
    lesson_count = 0
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            for line_num, line in enumerate(file, 1):
                line = line.strip()
                if not line:  # Skip empty lines
                    continue
                
                # Use regex to find time pattern (MM:SS) at the end of the line
                time_match = re.search(r'\((\d+):(\d{2})\)$', line)
                
                if time_match:
                    time_str = f"{time_match.group(1)}:{time_match.group(2)}"
                    lesson_seconds = parse_time_to_seconds(time_str)
                    total_seconds += lesson_seconds
                    lesson_count += 1
                    
                    # Extract lesson name (everything before the time)
                    lesson_name = re.sub(r'\s*\(\d+:\d{2}\)$', '', line)
                    print(f"✓ {lesson_name}: {time_str}")
                else:
                    print(f"⚠ Line {line_num}: Could not parse time - '{line}'")
    
    except FileNotFoundError:
        print(f"❌ Error: File not found at {file_path}")
        print("Please check that the file exists and the path is correct.")
        return None
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return None
    
    return total_seconds, lesson_count

def main():
    # File path
    file_path = r"C:\dev\inputfiles\sysadmin_name_time.txt"
    
    print("🎓 Course Time Calculator")
    print("=" * 50)
    print(f"Reading file: {file_path}")
    print()
    
    # Check if file exists
    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        print("Please make sure the file exists at the specified location.")
        return
    
    result = calculate_course_time(file_path)
    
    if result:
        total_seconds, lesson_count = result
        
        print("\n" + "=" * 50)
        print("📊 SUMMARY")
        print("=" * 50)
        print(f"Total lessons found: {lesson_count}")
        print(f"Total time: {seconds_to_readable(total_seconds)}")
        
        # Additional time breakdowns
        total_minutes = total_seconds / 60
        total_hours = total_seconds / 3600
        
        print(f"Total minutes: {total_minutes:.1f}")
        print(f"Total hours: {total_hours:.2f}")
        
        # Estimate completion times
        print("\n📅 COMPLETION ESTIMATES:")
        print(f"• 1 hour/day: {total_hours:.1f} days")
        print(f"• 2 hours/day: {total_hours/2:.1f} days") 
        print(f"• 30 min/day: {total_hours*2:.1f} days")
        
        print(f"\n💡 If studying 1 hour per day, you'll complete the course in approximately {int(total_hours) + (1 if total_hours % 1 > 0 else 0)} days")

if __name__ == "__main__":
    main()