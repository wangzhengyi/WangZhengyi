# 从函数到 Agent：LLM Tools 全面指南（工程落地版）

> 适用人群：已经在用 ChatGPT / 通义 / 豆包做开发，希望把工具调用落地到项目的工程师。

**摘要**
- 工具（Tools）本质是“给 LLM 用的函数”，用来补齐“最新信息、算术可靠性、外部系统访问”等短板。
- 从用户提问到工具结果复述的链路包括：工具描述 → 调用意图 → 真调用 → 结果回填 → 最终答复。
- 在工程实践中，推荐用“函数签名 + 装饰器 + MCP（标准接口）”统一工具定义与接入方式。

**关键词**
- `LLM Tools`、`函数调用`、`Agent`、`MCP`、`装饰器`、`工程落地`

---

## 为什么需要工具（Tools）

LLM 只会“看文本 → 回文本”，没有访问互联网、数据库或公司内部 API 的原生能力。常见痛点：

- 复杂算术不可靠；
- 最新信息（如当天天气、股票价格）无法直接获取；
- 无法主动触达外部系统（HTTP、SQL、企业服务）。

用工具把“外部世界”封装成一个个函数，让 LLM 可以提出调用建议，我们的系统负责真实执行。

### 常见工具类型与场景

| 工具类型 | 补充能力 | 典型例子 |
| --- | --- | --- |
| Web Search（网页搜索） | 获取最新外部信息 | 查天气、赛事比分 |
| Calculator（计算器） | 可靠数值计算 | 金融计算、统计、公式计算 |
| Retrieval（检索） | 访问文档/数据库 | 私有知识库问答、RAG |
| API Interface（API） | 调用外部系统 | GitHub、Slack、飞书、内部服务 |
| Image Generation（绘图） | 多模态生成 | 文生图、封面图生成 |

---

## 一条完整的数据链路：从提问到工具调用

以“查巴黎天气”为例：

1) 用户提问（UI）
- 用户：现在巴黎多少度？
- 用户只看到对话框，不感知“工具”的存在。

2) Agent 提供工具描述（系统提示）
- 告诉 LLM 有一个 `weather_tool`，说明作用、输入参数、输出结构。

3) LLM 产生“调用建议”（非真调用）

```json
{
  "tool_name": "weather_tool",
  "arguments": { "city": "Paris" }
}
```

4) Agent 真调用工具（系统执行）

```python
result = weather_tool(city="Paris")
# 例如：{"temp_c": 18, "condition": "Cloudy"}

messages.append({
    "role": "tool",
    "name": "weather_tool",
    "content": '{"temp_c": 18, "condition": "Cloudy"}'
})
```

5) LLM 基于结果生成自然语言回复
- 助手：现在巴黎大约 18°C，多云，出门记得带件薄外套。

---

## Tool 的构成要素（工程视角）

一个合格的 Tool 至少包含：

- 名称 `name`：可引用的唯一标识；
- 描述 `description`：自然语言说明用途；
- 参数 `arguments`：参数名、类型、含义；
- 返回 `outputs`（可选）：结构与字段含义；
- 可调用对象 `func`：真实执行的 Python 函数 / 脚本。

调用前，LLM 需要清楚“要传哪些参数、类型/边界如何、返回结构长什么样”，否则容易“调用错工具”或“参数传乱”。

---

## 用装饰器把函数“包装成 Tool”

手写工具描述容易错，推荐用“函数签名 + docstring”作为单一事实来源，通过装饰器自动生成 Tool 描述。

```python
from typing import Callable, List, Tuple
import inspect

class Tool:
    def __init__(self, name: str, description: str, func: Callable,
                 arguments: List[Tuple[str, str]], outputs: str):
        self.name = name
        self.description = description
        self.func = func
        self.arguments = arguments
        self.outputs = outputs

    def to_string(self) -> str:
        args_str = ", ".join(f"{n}: {t}" for n, t in self.arguments)
        return (
            f"Tool Name: {self.name}\n"
            f"Description: {self.description}\n"
            f"Arguments: {args_str or 'None'}\n"
            f"Outputs: {self.outputs}"
        )

    def __call__(self, *args, **kwargs):
        return self.func(*args, **kwargs)

def tool(func: Callable) -> Tool:
    signature = inspect.signature(func)

    arguments: List[Tuple[str, str]] = []
    for p in signature.parameters.values():
        ann = p.annotation
        tname = "Any" if ann is inspect._empty else getattr(ann, "__name__", str(ann))
        arguments.append((p.name, tname))

    outputs = (
        "Any" if signature.return_annotation is inspect._empty
        else getattr(signature.return_annotation, "__name__", str(signature.return_annotation))
    )

    description = (func.__doc__ or "No description provided.").strip()
    return Tool(func.__name__, description, func, arguments, outputs)

@tool
def calculator(a: int, b: int) -> int:
    """Multiply two integers."""
    return a * b

print(calculator.to_string())
```

示例输出：

```
Tool Name: calculator
Description: Multiply two integers.
Arguments: a: int, b: int
Outputs: int
```

此时 `calculator` 既是一个 Tool（供 LLM 使用的结构化描述），又是一个可调用对象（`calculator(2, 3) -> 6`），方便 Agent 直接执行。

---

## 用 MCP 标准化“工具接口”

随着工具增多、模型与框架切换频繁，建议逐步接入 Model Context Protocol（MCP）：

- 预构建工具集成：常用能力已有适配，可开箱即用；
- 模型可互换：更换模型供应商，仅调整上游对接；
- 数据安全治理：更易于符合企业合规；
- 跨框架复用：一套 MCP 工具可被多个 Agent 框架复用。

企业自建 LLaMA / Qwen / InternLM 等时，统一访问公司 API / 数据库，走 MCP 比各框架各写一套 Tool 接口更省心。

---

## 工程落地清单（Checklist）

1. 列出业务场景的必要工具
- 算术/统计：calculator、财务指标计算；
- 信息：知识库检索、工单查询；
- 操作：创建任务、发消息、更新工单状态。

2. 用“函数 + 装饰器”统一定义工具
- 函数签名即参数契约；docstring 即自然语言描述；
- 装饰器产出 Tool 结构，避免手写 JSON。

3. 在 Agent 层实现“调用意图 → 真调用”的桥接
- 解析 LLM 输出（如 JSON）拿到 `tool_name` 与参数；
- 从 `tools_registry` 查找对应 Tool；
- 执行 `tool(**arguments)`，并把结果回填到对话消息。

4. 逐步接入 MCP 或其他标准协议
- 个人项目可暂缓；团队/平台级尽早标准化，降低未来接入成本。

5. 调试时打印“LLM 看到的工具描述”
- 大部分“调用错工具/参数传乱”的问题是描述不清；
- 确认参数含义、边界、类型已清晰表达。

---

## 小结与下一步

核心要点：
- Tool 是“给 LLM 用的函数”，补齐信息与能力短板；
- LLM 只提出“调用建议”，真实调用由你的 Agent 执行；
- 合格的 Tool 不只是函数，还包含结构化描述与参数契约；
- 装饰器 + introspection 可自动从 Python 函数生成 Tool；
- MCP 正在标准化工具接口，有助于跨模型/跨框架复用。

下一步：结合「Thought-Action-Observation」循环，把工具调用嵌入完整 Agent 流程。届时，LLM 不再只是“会聊天”，而是能“想 → 调用工具 → 看结果 → 再想”的半自动化协作伙伴。
