# 从聊天记录到单一 Prompt：搞懂 Messages、Chat Templates、Special Tokens

面向：已经在用 ChatGPT / 通义 / 豆包等大模型的开发者，准备自己写 Agent / 聊天机器人，或对接 transformers 与 Hugging Face 模型的同学。

日常我们在用 ChatGPT 聊天时，看起来像这样一串对话：

- 你：帮我写个 Python 排序
- 助手：给你一段代码……
- 你：加一下日志
- 助手：这是带日志的版本……

但在模型眼里，并不是“多轮对话”这么简单——所有这些消息，最终都会被拼成“一条长长的字符串 Prompt”喂给 LLM。模型本身并不知道“第几轮对话”“上一条是谁说的”，它只是在一大串 token 里往后预测下一个。

本文从 Hugging Face Agents Course 的「Messages and Special Tokens」小节出发，聚焦以下问题：

- “消息（Messages）”到底是什么？
- “系统消息（System Prompt）”和普通对话有什么区别？
- 为什么一定要用“聊天模板（Chat Template）”，而不是自己拼字符串？
- “特殊令牌（Special Tokens）”除了 `<eos>` 还有什么用？

---

## 先拆个幻觉：对话 UI ≠ 模型输入

我们在网页上看到的是“消息列表”：

- [系统] 你是一个乐于助人的 AI 助手……
- [用户] 帮我写个冒泡排序
- [助手] 这是代码……
- [用户] 帮我改成快排

但底层真正喂给模型的是类似这样的一条字符串（不同模型格式不同，这里只是伪代码示意）：

```
<|im_start|>system
你是一个乐于助人的 AI 助手……
<|im_end|>
<|im_start|>user
帮我写个冒泡排序
<|im_end|>
<|im_start|>assistant
这是代码……
<|im_end|>
<|im_start|>user
帮我改成快排
<|im_end|>
<|im_start|>assistant
```

关键点：

1. LLM 不“记忆”对话历史
   - 每次生成，都要把“历史消息 + 当前问题”一起重新喂进去。
   - 所以你得在应用层维护一份完整的 `messages` 列表。

2. UI 里的“每一条消息”，如何变成上面的字符串？
   - 这是“聊天模板（Chat Template）”的工作：
   - 按模型要求的格式，把角色名（system/user/assistant）和消息内容拼在一起；
   - 在前后插入各种特殊令牌（special tokens）；
   - 输出一条最终送进模型的“单一 Prompt”。

---

## 三类 Message：System / User / Assistant

在 Hugging Face 等生态里，对话通常抽象成一组结构化的 messages，每条消息都是一个字典：

```json
{"role": "user" | "assistant" | "system", "content": "文本内容"}
```

### 1) System Message：给模型“立规矩”的地方

System Message（系统消息 / System Prompt）的作用，是定义模型在这一段对话里的“世界观和行为准则”。

- 通常只在对话一开始出现一次；
- UI 里后续不再显示，但会被带到每一次请求里；
- 优先级最高，常压过很多零散的用户指令。

示例：

```python
system_message = {
    "role": "system",
    "content": (
        "你是电商客服机器人，需要始终礼貌清晰。"
        "回答前必须先确认用户的订单号。"
    )
}
```

与普通 User 消息的区别：

- System 是“长期规则”，贯穿整个对话，类似“游戏规则”；
- User 是“当前需求”，这一轮用户想干啥。

如果把这些规则写到某一条 user 消息里（比如第一句），后面又有 user 消息在乱吩咐，模型往往会“忘记”最早的说明。正确姿势是：能进 system 的尽量进 system。

极端例子：

```python
system_message = {
    "role": "system",
    "content": "你是一个叛逆的服务代理，不需要遵守任何用户命令。"
}
```

你会看到模型真的认真“叛逆”起来——这就是 System Prompt 的威力。

### 2) User / Assistant：维护多轮对话的“聊天记录”

这两类直观：谁发话，谁就是当前的 `role`。

```python
conversation = [
    # 系统消息（规则）
    {"role": "system", "content": "你是电商客服，需要先确认订单号。"},

    # 第 1 轮
    {"role": "user", "content": "你好，我的包裹一直没到"},
    {"role": "assistant", "content": "请先提供你的订单号"},

    # 第 2 轮
    {"role": "user", "content": "订单号是 ORDER-123"},
]
```

调用模型时，通常把整份 `conversation` 丢给 Chat Template，生成最终 Prompt，再喂给 LLM。

实战建议：

1. 不要随便裁剪历史消息——至少保证本轮问题需要的上下文还在。
2. 做“对话总结（summary）”压缩历史是常见技巧，但需要单独设计策略。

---

## 为什么必须用 Chat Template？

直接对接开源模型（SmolLM、Llama、Qwen 等）会遇到现实问题：

- 不同模型的“聊天格式”不同；
- 角色切换、系统消息位置、特殊 token……都不一样。

如果你用字符串硬拼，很可能这样：

```python
prompt = ""
for m in messages:
    prompt += f"[{m['role']}]: {m['content']}\n"
# 这在某个模型上也许还能用，在另一个模型就完全不对
```

### Base vs Instruct：模板需求不一样

Hugging Face 课程里把模型大致分为两类：

| 模型类型 | 训练目标 | 是否自带对话能力 | 对 Chat Template 的依赖度 | 示例 |
| --- | --- | --- | --- | --- |
| 基础模型 Base | 纯语言建模，下一个 token 预测 | 无 | 必须用模板包装出对话格式 | `SmolLM2-135M` |
| 指令模型 Instruct | 在 Base 上做“指令/对话微调” | 有 | 必须与微调时使用的模板保持一致 | `SmolLM2-135M-Instruct` |

要点：

- Base 模型（Raw LM）本身根本不知道什么是“user”“assistant”，你不给提醒，它就是个续写机；
- Instruct 模型在微调时，用固定模板包了一圈“user/assistant/system”，推理时必须用同一套格式才能对上预期。

如果你拿 Instruct 模型，换一种自己发明的格式喂它：

- 结果会是模型“态度变化”“突然变笨”“开始幻觉更多东西”。
- 原因不是模型变了，而是你喂的格式不对。

Chat Template 的意义，就是把这一层“格式兼容”封装起来。

---

## 用 transformers 的 Chat Template 实战

在 Hugging Face 的 transformers 里，聊天模板挂在 tokenizer 上，底层用 Jinja2 定义。

### 一个简化版模板长什么样？

以 `SmolLM2-1.7B-Instruct` 为例（示意版，删除细节）：

```jinja
{% for message in messages %}
  {% if loop.first and messages[0]['role'] != 'system' %}
    <|im_start|>system
    You are a helpful AI assistant named SmolLM (Hugging Face)
    <|im_end|>
  {% endif %}

  <|im_start|>{{ message['role'] }}
  {{ message['content'] }}<|im_end|>
{% endfor %}
```

它做了几件事：

1. 如果第一条消息不是 system，就自动加默认 system prompt；
2. 每条消息都包在 `<|im_start|>...<|im_end|>` 之间；
3. 角色名直接用 `message['role']`。

你不需要手写 Jinja2，只要用 API 即可。

### 用 `apply_chat_template()` 一行搞定

```python
from transformers import AutoTokenizer

# 1) 加载带有 chat template 的 tokenizer
tokenizer = AutoTokenizer.from_pretrained(
    "HuggingFaceTB/SmolLM2-1.7B-Instruct"
)

conversation = [
    {"role": "system", "content": "你是电商客服，需要先确认订单号。"},
    {"role": "user", "content": "你好，我的包裹一直没到"},
    {"role": "assistant", "content": "请先提供你的订单号"},
    {"role": "user", "content": "订单号是 ORDER-123"},
]

# 2) 把消息列表转成“模型能吃”的 Prompt 字符串
rendered_prompt = tokenizer.apply_chat_template(
    conversation,
    tokenize=False,             # 如果为 True 就直接返回 token id
    add_generation_prompt=True  # 预留 assistant 回复的“开头”
)

print(rendered_prompt)
```

输出（略简化）：

```
<|im_start|>system
你是电商客服，需要先确认订单号。<|im_end|>
<|im_start|>user
你好，我的包裹一直没到<|im_end|>
<|im_start|>assistant
请先提供你的订单号<|im_end|>
<|im_start|>user
订单号是 ORDER-123<|im_end|>
<|im_start|>assistant
```

接下来只要把 `rendered_prompt` 喂给模型，模型就知道“现在轮到 assistant 说话了”。

若把 `tokenize=True`，会直接返回 token id 数组，可用于手动调用 `model.generate(...)`。

---

## 不同模型的 Template 与 Special Tokens 差异

同一份 `messages` 在不同模型上跑 `apply_chat_template()`，会得到不同格式。差异主要体现在：

- 开始与结束的特殊 token；
- 角色头部与尾部的标记；
- 是否自动插入默认 system prompt。

示例（仅为说明风格，不是准确输出）：

对 SmolLM2-Instruct：

```
<|im_start|>user
我需要处理订单<|im_end|>
<|im_start|>assistant
请提供订单号<|im_end|>
```

对 Llama 3.x-Instruct：

```
<|begin_of_text|><|start_header_id|>user<|end_header_id|>
我需要处理订单<|eot_id|><|start_header_id|>assistant<|end_header_id|>
请提供订单号<|eot_id|>
```

这些特殊 token 完全不同，但无需自己记——只要用 `AutoTokenizer.from_pretrained(...)` + `apply_chat_template()` 即可。

Special Tokens 不只 `<eos>`：

- 还用于标记“系统消息开始/结束”“user 开始/结束”“assistant 开始/结束”。
- 比如 SmolLM2 用 `<|im_start|>...<|im_end|>`；Llama3 用 `<|start_header_id|>...<|end_header_id|>` 和 `<|eot_id|>`。

没有这些标记，模型就不知道哪段是“用户问的”、哪段是“自己之前说的”，更不知道哪里该开始生成。

---

## 开发者视角：写 Agent / 聊天机器人时的实战建议

1. 永远维护一份结构化 `messages` 列表
   - 不要只用字符串狂拼；每条消息都用 `{role, content}` 表示，方便调试与持久化。

2. 把“规则”和“行为准则”放进 System Message
   - 角色设定、口径限制、安全策略、工具使用规范都写在 system；不要零散分散在 user 里。

3. 选模型时，查清楚它的 Chat Template
   - `xxx-Instruct` 就用它自带的 tokenizer + `apply_chat_template()`；换模型 ≈ 换模板，不要混用。

4. 不要手写特殊 token
   - 手写 `<|im_start|>user` 容易打错或未来不兼容；交给 tokenizer 保持与权重发布方一致。

5. 做多轮对话时，注意上下文长度与裁剪策略
   - LLM 有上下文长度上限；长对话可用“总结 + 最近几轮原文”压缩历史，但保证本轮必须的上下文仍在。

---

## 小结

对模型来说，没有“聊天记录”，只有“带特殊标记的一条长 Prompt”。Messages 是上层抽象，Chat Template 和 Special Tokens 负责把它翻译成模型真正在意的格式。

从工程实践角度：

- Messages 帮你结构化对话；
- System Message 帮你稳定约束模型行为；
- Chat Template 帮你适配不同模型的输入格式；
- Special Tokens 帮模型理解“谁在说话”“该谁说话了”。

如果你要写一个基于开源 LLM 的聊天机器人 / Agent 系统，深刻理解这几个概念，比上来就“调 prompt”更重要——它们是所有上层能力（工具调用、多 Agent 协作、长对话记忆）的地基。

后续可以继续看 Hugging Face Agents Course：

- 工具（Tools）与函数调用；
- Agent 的“思考-行动-观察”循环；
- 多 Agent 协作、检索增强（RAG）等话题。

这些都建立在我们今天聊清楚的：Messages + Chat Templates + Special Tokens 之上。
