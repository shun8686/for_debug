import json

file_path="test_suite_config.json"

def get_test_cases(model_name: str) -> list:
    test_cases = []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            json_array = json.load(f)

        if not isinstance(json_array, list):
            print(f"Error：{file_path} is not json array!")
            return test_cases

        model_sets = [
            item for item in json_array 
            if item.get("model_name") == model_name
        ]

        test_cases = model_sets[0].get("test_cases")

    except FileNotFoundError:
        print(f"Error: file {file_path} not exist!")
    except json.JSONDecodeError:
        print(f"Error: {file_path} JSON file decode error!")
    except Exception as e:
        print(f"Error: {str(e)}")
    
    return test_cases

if __name__ == "__main__":
    model_name = "Qwen3"
    result = get_test_cases(model_name)
    print("length: {}".format(len(result)))
    



