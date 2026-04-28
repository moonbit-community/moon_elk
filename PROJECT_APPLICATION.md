# Moon ELK 项目申报书

## 基本信息

- 项目名称：Moon ELK：Eclipse Layout Kernel 的 MoonBit 移植
- 参赛者 / 团队名称：待补充
- 项目负责人：待补充
- 联系方式：待补充
- GitHub 仓库链接：https://github.com/moonbit-community/moon_elk.git
- 项目方向：MoonBit 图布局基础库 / 可视化基础设施 / 开源生态移植
- 是否为移植项目：是

## 项目简介

Moon ELK 计划将 Eclipse Layout Kernel（ELK）的核心图布局能力移植到 MoonBit 生态，为流程图、数据流图、状态机、建模工具、IDE 插件、低代码编辑器和可视化分析工具提供可复用的自动布局引擎。项目面向需要在 MoonBit 中构建或处理图结构的库作者、工具开发者和应用开发者，提供 ElkGraph 数据模型、JSON 导入导出、布局选项解析、布局算法调度以及多种常用布局算法的 MoonBit 实现。ELK 在 Java 与 JavaScript 生态中已被广泛用于复杂图形界面的自动排版，但 MoonBit 生态目前缺少同等级的图布局基础设施。本项目能够补齐图形化工具链的重要基础能力，让 MoonBit 项目可以直接完成图模型构建、布局计算、结果序列化和跨端渲染对接，也能为后续 IDE、建模、可视化和文档图生成工具提供稳定底座。

## 核心功能范围

- 提供 ElkGraph 风格的图模型，支持节点、边、端口、标签、层级节点和布局属性；
- 支持 ELK JSON 格式的导入、导出和 pretty print，便于与前端渲染器或现有 ELK 工具链交换数据；
- 提供统一布局入口 `new_elk_engine().layout(...)`，支持按 `elk.algorithm` 分发算法；
- 支持 Layered、Force、Stress、Radial、MrTree、RectPacking、Spore、Fixed、Box、Random、Vertiflex 等布局能力；
- 支持基础布局选项解析，包括方向、间距、端口约束、节点尺寸、边路由和算法特定配置；
- 提供算法元数据、服务注册、布局校验和调试辅助模块；
- 提供 Graph Text / ELK Text 相关解析和转换能力的基础实现；
- 提供与 elkjs / ELK 参考实现对照的差异测试、随机用例和迁移记录；
- 提供不少于 300 个 MoonBit 测试文件，并持续保持核心回归测试通过；
- 提供 README 示例，覆盖 JSON 布局、图模型构建、JSON 导入导出和算法选择。

## 技术路线

项目采用多包结构组织 MoonBit 代码，源码位于 `src` 目录，各子目录通过独立 `moon.pkg` 声明包依赖。整体模块划分如下：

- `core`：提供布局引擎、布局选项、算法装配、校验、数学工具、服务注册和调试支持；
- `graph`：实现 ELK 图模型，包括节点、边、端口、标签、属性和层级关系；
- `graph/json`：负责 ELK JSON 与 MoonBit 图模型之间的导入导出；
- `graph/text` 与 `graph/json/text`：承载文本格式、解析、序列化和 IDE/UI 相关扩展；
- `alg/layered`、`alg/force`、`alg/radial`、`alg/mrtree`、`alg/rectpacking`、`alg/spore` 等：按算法族拆分布局实现；
- `alg/graphviz`、`alg/libavoid`、`alg/disco`、`alg/topdownpacking` 等：保留参考、兼容或后续扩展入口；
- `diff` 与 `artifacts`：维护与 elkjs / ELK 参考实现的行为对照、随机案例和差异分析。

关键实现思路是先建立与 ELK 相近的图数据结构和布局选项体系，再将 Java / JavaScript 参考实现中的算法阶段逐步拆解为 MoonBit 包内的类型、函数和测试。布局入口通过 `ElkEngine::layout` 合并默认选项、调用参数和图内布局选项，解析算法名称后分发到具体布局 provider。算法实现保持阶段化结构，例如 Layered 布局按 cycle breaking、layer assignment、crossing minimization、node placement、edge routing 等阶段组织。项目将持续使用 MoonBit 的强类型、枚举、模式匹配、包系统、JSON 库、测试快照、`moon info` 生成接口文件、`moon fmt` 格式化和 `moon test` 回归验证。

## 移植或参考说明

- 原项目名称：Eclipse Layout Kernel（ELK）
- 原项目链接：https://github.com/eclipse-elk/elk
- 原项目许可证：Eclipse Public License 2.0
- 辅助参考项目：elkjs
- 辅助参考链接：https://github.com/kieler/elkjs
- 辅助参考许可证：Eclipse Public License 2.0
- 本项目许可证：Apache License 2.0

本项目计划移植或重写 ELK 中面向通用图布局的核心能力，包括 ElkGraph 数据模型、布局选项、布局算法调度、JSON 格式互操作和主要布局算法。当前重点范围覆盖 Layered、Force、Stress、Radial、MrTree、RectPacking、Spore、Fixed、Box、Random、Vertiflex 等在 elkjs 中可直接使用的算法族，并以本仓库内的 `elk-reference`、`elkjs-reference`、`elk-models` 和 `artifacts/diff` 作为参考材料与对照测试来源。

与原项目相比，本项目会做以下简化和重新设计：

- 使用 MoonBit 原生包结构、类型系统和测试方式组织代码，而不是复刻 Java 插件工程结构；
- 优先实现可在 MoonBit 中独立运行的核心布局能力，弱化 Eclipse UI、OSGi、SWT/JFace 等桌面插件依赖；
- 对 Graphviz、libavoid、disco、topdownpacking 等当前暂不完整支持的算法保留兼容入口和错误行为，作为后续扩展范围；
- 对 Java 异常、集合类型、继承层级和服务发现机制进行 MoonBit 化改写；
- 以 JSON 输入输出和 MoonBit API 为主要交付界面，方便接入 Web、CLI、IDE 和可视化渲染场景。

## AI 使用计划

- 使用 AI 辅助理解 ELK / elkjs 中的算法阶段、类型关系和边界条件；
- 使用 AI 生成迁移清单、包拆分建议和 Java / JavaScript 到 MoonBit 的重写草稿；
- 使用 AI 补充黑盒测试、白盒测试、随机回归用例和快照测试；
- 使用 AI 对照 ELK 参考实现分析输出差异，定位坐标、边路由、端口、标签和层级节点相关问题；
- 使用 AI 辅助整理 README、API 示例、迁移报告、差异报告和开发文档；
- 使用 AI 做代码审查式检查，关注布局行为回归、未覆盖分支、错误处理和公开 API 变动。

## 预期交付物

- MoonBit 源代码，包含核心图模型、JSON 互操作和多种布局算法；
- `README.mbt.md` / `README.md`，提供安装、导入、最小示例和算法支持说明；
- 示例代码，覆盖 JSON 输入布局、MoonBit 图模型构建、JSON 导入导出；
- 测试套件，包含单元测试、白盒测试、快照测试、参考实现对照测试和随机案例；
- `LICENSE`，明确本项目 Apache License 2.0 授权；
- `pkg.generated.mbti`，记录各包公开 API；
- 迁移报告与状态记录，包括 `STATUS.md`、`migration/` 和 `artifacts/diff/`；
- 可选交付物：演示视频、博客文章、布局结果截图、API 文档、与前端渲染器集成示例。
