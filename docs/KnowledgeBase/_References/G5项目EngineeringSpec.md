# G5 项目工程结构 Spec（Godot）

**版本:** 1.0
**适用引擎:** Godot 4.x
**设计核心:** **高内聚，低耦合，所见即所得。**
**维护目标:** 让程序员在一个文件夹内就能完成一个功能的全部闭环（逻辑+表现），同时通过严格的数据规范支持敏捷迭代。

---

## 0. 文档位置与工程协作

- 工程规范文档位置：`Docs/Technical/EngineeringSpec.md`
- 顶层宪法与总规范：根目录 `CONSTITUTION.md`
- 项目文档入口：`Docs/README.md`（已配置 `.gdignore`，Godot 将忽略 `Docs` 目录）
- 开发纪要（Dev Logs）：`Docs/KnowledgeBase/DevLogs/YYYYMMDD_主题.md`
- 待办计划（TODO）：`Docs/TODO.md`（采用“高/低 + 例行 + 归档”结构）

---

## 1. 根目录结构概览 (`res://`)

根目录保持扁平，通过文件夹名称清晰区分“实体”、“数据”、“界面”和“资源”。

```text
res://
├── _Autoloads/            # [全局] 单例与管理器 (Global Only)
│   ├── GameEvents.gd      # 信号总线 (解耦的关键)
│   ├── GameManager.gd     # 游戏流程控制
│   └── AudioMgr.gd        # 音频管理
│
├── Assets/                # [资源] 原始美术与音频素材
│   ├── _Placeholders/     # [重点] 所有的原型灰盒资源 (Cube, Capsule, Icons)
│   ├── Audio/
│   ├── Fonts/
│   └── Textures/          # 通用纹理 (UI背景, 地面纹理)
│
├── Data/                  # [配置] 纯数据文件 (策划/数值的工作区)
│   ├── Resources/         # .tres 实例文件 (如: Soldier_L1.tres, Map_Config.tres)
│   └── Tables/            # JSON/CSV 表格 (多语言, 复杂数值表)
│
├── Gameplay/              # [核心] 游戏实体模块 (按"东西"分类)
│   ├── Camera/            # 相机控制系统 (CameraRig)
│   ├── Factions/          # 阵营颜色配置与逻辑
│   ├── Map/               # 大地图相关
│   │   ├── Scripts/       # 地图生成、寻路算法
│   │   ├── Scenes/        # 地块(Hex/Grid)预制体
│   │   └── Resources/     # 地图特有的数据定义 (MapData.gd)
│   ├── Units/             # 军事单位 & 自走棋相关
│   │   ├── Components/    # 通用组件 (HealthComp, AttackComp)
│   │   ├── Logic/         # 战斗AI, 状态机脚本
│   │   └── Prefabs/       # 兵种预制体 (Archer.tscn, Cavalry.tscn)
│   └── Economy/           # 经济与建设系统
│       └── Buildings/     # 建筑预制体与逻辑
│
├── UI/                    # [界面] 所有用户界面
│   ├── Common/            # 通用控件 (MyButton.tscn, HealthBar.tscn)
│   ├── HUD/               # 战斗飘字、头顶血条
│   ├── Menus/             # 全屏菜单 (MainMenu, TechTree, Settle)
│   └── Panels/            # 局部面板 (UnitInfo, ResourceBar)
│
├── Scenes/                # [入口] 游戏运行与测试场景
│   ├── MainEntry.tscn     # 游戏主入口（现状为 `Scenes/main_entry.tscn`，后续可统一为 PascalCase）
│   ├── _Sandboxes/        # [测试] 开发者个人的测试场
│   │   ├── Test_Combat.tscn # 纯战斗逻辑验证
│   │   └── Test_MapGen.tscn # 地图生成验证
│   └── Levels/            # 正式关卡 (如有)
```

---

## 2. 核心开发规则 (The Rules)

针对团队特点，制定以下三条铁律，确保工程在迭代中不腐化。

### 规则一：所见即所得 (Co-location)
*   **原则**：实现一个功能（比如“弓箭手”）所需的所有**独有**资源，尽量放在同一个目录下。
*   **执行**：
    *   弓箭手的模型场景 (`Archer.tscn`)
    *   弓箭手的攻击脚本 (`ArcherAttack.gd`)
    *   弓箭手的专用特效 (`ArrowTrail.tscn`)
    *   **全部放在 `Gameplay/Units/Prefabs/Archer/` (或者类似的子目录) 下。**
*   **目的**：当你想删除或重构“弓箭手”时，不用满世界找文件，删掉文件夹即可。

### 规则二：数据驱动 (Resource First)
*   **原则**：严禁在 Node 脚本 (`.gd`) 中写死数值（如攻击力、造价）。
*   **执行**：
    1.  程序在 `Gameplay` 目录写数据定义脚本：`class_name UnitData extends Resource`。
    2.  在 Inspector 中右键新建 Resource，保存到 `Data/Resources/` 目录（例如 `Archer_L1.tres`）。
    3.  Node 脚本中通过 `export var data: UnitData` 读取。
*   **目的**：发挥团队代码能力（写结构定义），同时避免因频繁调整数值而修改代码文件，减少 Git 冲突。

### 规则三：信号解耦 (Signal Only Upwards)
*   **原则**：子节点可以直接调用父节点/组件（向下/平级），但**绝不允许**直接调用上级系统或跨模块系统（向上/跨级）。
*   **执行**：
    *   ❌ 错误：`Unit.gd` 写 `get_node("/root/Main/UI").update_health()`
    *   ✅ 正确：`Unit.gd` 写 `signal health_changed(new_val)` -> UI 监听这个信号。
    *   ✅ 跨模块：使用 `_Autoloads/GameEvents.gd`。
        *   单位死亡时：`GameEvents.unit_died.emit(self)`
        *   游戏管理器：`GameEvents.unit_died.connect(_on_unit_death)`

---

## 3. 针对 G5 原型的具体实施细则

### 3.1 核心循环实现路径
1.  **军事单位 (Gameplay/Units)**:
    *   创建 `UnitBase.tscn`，挂载 `HealthComponent`, `MoveComponent`。
    *   验证：在 `Scenes/_Sandboxes/Test_Combat.tscn` 中放置两个 Unit，测试互殴。
2.  **大地图 (Gameplay/Map)**:
    *   使用 `TileMapLayer` 或 GridMap。
    *   数据层：编写纯 GDScript 类 `GridManager` 处理坐标与占领逻辑，不依赖具体场景节点。
3.  **UI 集成 (UI/)**:
    *   UI 只负责显示。UI 脚本中应该持有 `GameManager` 或 `Unit` 的引用，并连接它们的信号来更新显示。

### 3.2 应对“频繁增减内容”的策略
*   **Assets/_Placeholders**:
    *   工程初期，严禁等待美术资源。
    *   士兵用 `CapsuleMesh` (胶囊体)，城镇用 `BoxMesh` (方块)。
    *   颜色编码：红色=敌军，蓝色=友军，黄色=资源点。
    *   当需要修改视觉风格时，只需修改 `.tscn` 中的 Mesh 引用，不影响逻辑。

### 3.3 多人协作分工建议
*   **程序 A (擅长算法)**: 负责 `Gameplay/Map` (地图生成) 和 `Gameplay/Units/Logic` (自走棋寻路/战斗公式)。
*   **程序 B (擅长逻辑)**: 负责 `Gameplay/Economy` (资源循环) 和 `_Autoloads/GameManager` (回合流程)。
*   **程序 C / 技术美术**: 负责 `UI/` 和 `Assets/` (表现层)。
*   **策划**: 负责 `Data/Resources` (配置数值) 和 `Scenes/_Sandboxes` (搭建测试关卡)。

---

## 4. 命名与文件规范

为了减少沟通成本，统一使用以下命名法：

| 类型 | 格式 | 示例 | 备注 |
| :--- | :--- | :--- | :--- |
| **文件夹** | PascalCase | `Gameplay`, `MapSystem` | 清晰的大分类 |
| **脚本 (.gd)** | PascalCase | `UnitController.gd` | 必须在文件头写 `class_name UnitController` |
| **场景 (.tscn)** | PascalCase | `MainMenu.tscn` | 与脚本名保持一致 |
| **资源 (.tres)** | snake_case | `soldier_lv1.tres` | 数据实例用小写 |
| **信号 (Signal)** | snake_case | `signal health_changed` | |
| **私有函数** | _snake_case | `func _calculate_damage()` | 下划线开头，明确告知他人“别在外部调这个” |

---

## 5. 快速启动清单 (Checklist) — 对齐当前计划

1.  [x] 创建上述目录结构。
2.  [x] 配置 `.gitignore` (忽略 `.godot/`, `*.import`).
3.  [x] 创建 `_Autoloads/GameEvents.gd` (空的脚本，定义 `class_name GameEvents extends Node`)。
4.  [ ] 在 `Assets/_Placeholders` 里创建红、蓝、黄三种材质的临时模型。
5.  [x] 在 `Data/Resources` 里建立第一个测试数据（如 `GlobalConfig.tres`）。
6.  [ ] 搭建基本关卡场景与主入口（`Scenes/MainEntry.tscn` 或统一命名方案）
7.  [x] 构建可交互的大地图网格（四边形或六边形）
8.  [x] 实现俯视相机与基础镜头控制（平移/缩放/边缘滚动）
9.  [ ] 实现基础操作：点击选取与交互
10. [ ] 集成基础 UI 流（主界面、资源栏、报告面板）
11. [ ] 建立开发者沙盒场景（地图生成与战斗验证）

---

## 6. 与现有工程对齐（现状快照）

- 已存在目录：
  - `_Autoloads/`（GameEvents.gd、GameManager.gd、AudioMgr.gd）
  - `Scenes/`（包含 `main_entry.tscn`）
- 文档目录：
  - `Docs/`（含 `.gdignore`，下有 `GameDesign/`, `Technical/`, `KnowledgeBase/`）
  - 顶层索引：`Docs/README.md`
  - 宪法：根目录 `CONSTITUTION.md`
  - 待办：`Docs/TODO.md`（高/低 + 例行 + 归档）
