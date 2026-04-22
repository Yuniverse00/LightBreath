import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sense2quit/bloc/cubit/faqs_data_cubit.dart';


class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);


  @override
  _FaqItemState createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1), // 改为绿色阴影
            spreadRadius: 1,
            blurRadius: 3,
          )
        ],
      ),
      child: Column(
        children: [

          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.green.shade600, // 改为绿色
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FaqsPage extends StatefulWidget {
  const FaqsPage({Key? key}) : super(key: key);

  @override
  _FaqsPageState createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {

  final List<Map<String, String>> _appFaqList = [
    // 一、戒烟目标设置相关
    {
      "question": "修改戒烟目标后，已坚持天数、未坚持天数会重置吗？",
      "answer": "不会重置。修改目标（如切换戒烟类型、调整周期/减量参数）仅更新目标参数，已坚持天数、未坚持天数、开始日期等进度数据会保留；仅“删除戒烟目标”会清空所有数据并重置进度。"
    },
    {
      "question": "“坚持天数/未坚持天数”是如何记录的？可以手动修改吗？",
      "answer": "用户需在「戒烟打卡记录」页面标记“已吸烟”后自动计算，暂不支持修改除当天以外的数据。"
    },
    {
      "question": "逐步减量的“当日目标吸烟量”是怎么计算的？",
      "answer": "计算公式：当日目标量 = 初始每日吸烟量 -（已坚持天数 ÷ 减少周期天数）× 每周期减少量；若计算结果为负，默认显示“完全不吸烟”（0支）。"
    },

    // 二、吸烟检测（手环连接）相关
    {
      "question": "手环连接显示“未连接设备”该怎么处理？",
      "answer": "1. 确认手机与手环已配对且蓝牙开启；2. 确保手环已安装对应检测固件；3. 重启App或手环后重新进入“手环检测”页面；4. 检查手环电量（低电量可能导致连接失败）。"
    },
    {
      "question": "检测时长输入后无法修改，或开始检测按钮无反应？",
      "answer": "1. 检测时长仅支持数字输入（单位：秒），需确保输入非空且大于0；2. 开始检测前需填写“检测任务名称”（未填写会默认使用“默认吸烟检测”）；3. 若已开始检测，需先点击“停止检测”才能上传数据。"
    },

    // 三、戒烟打卡记录相关
    {
      "question": "误点“已吸烟”并保存后，如何修改为“未吸烟”？",
      "answer": "在当日打卡页面重新选择“未吸烟”（吸烟次数会自动重置为0），点击“确认打卡”即可覆盖原有记录，系统会同步调整未坚持天数和健康统计数据。"
    },
    {
      "question": "忘记当日打卡会影响进度统计吗？",
      "answer": "会影响。未打卡日期的吸烟量默认按0计算（视为“未吸烟”），若实际吸烟未打卡，会导致健康统计数据（如节省金额、尼古丁减少）与实际不符，建议每日及时打卡。"
    },

    // 四、健康数据统计相关
    {
      "question": "累计节省金额是怎么计算的？可以修改香烟单价吗？",
      "answer": "累计节省金额 = 每日（初始吸烟量 - 实际吸烟量）的总和 × 单支香烟价格；单支价格由“每包价格 ÷ 每包支数”计算得出，目前不支持修改每包价格。"
    },
    {
      "question": "肺功能改善预估的百分比是怎么来的？",
      "answer": "基于中国吸烟人群的临床数据：1周（10%）、1个月（20%）、3个月（40%）、1年（60%）、1年以上（80%），仅为预估参考，具体以个人身体状况为准。"
    },
    {
      "question": "近7天/30天趋势图的基准线（绿色虚线）代表什么？",
      "answer": "完全戒烟：基准线为0（目标无吸烟）；逐步减量：基准线为初始每日吸烟量（目标逐步降至0）；红色/橙色曲线代表实际每日吸烟量。"
    },

    // 五、家庭支持相关
    {
      "question": "发送的图片/视频/音频保存在哪里？可以删除吗？",
      "answer": "所有媒体文件保存在App专属存储目录，删除消息时会自动删除对应的媒体文件；手动修改发送者名称不会影响文件存储。"
    },
    {
      "question": "音频播放时进度条不动，或播放完无法暂停？",
      "answer": "1. 音频加载需要时间，加载完成后自动更新；2. 播放完成后会自动暂停并重置进度，若异常可退出页面重新进入。"
    },
    {
      "question": "录制语音时提示“未获取麦克风权限”？",
      "answer": "需在手机设置中为App开启麦克风权限（设置→应用→该App→权限→麦克风），开启后重新进入“家庭支持”页面即可正常录音。"
    },

    // 六、戒烟知识库相关
    {
      "question": "戒烟知识库的视频无法播放，提示“加载失败”？",
      "answer": "1. 视频为网络文件，若未连接互联网会导致加载失败；2. 重启App或重进页面可解决；3. 确保手机存储空间充足（至少100MB）。"
    },
    {
      "question": "戒断阶段的“5分钟法则”“穴位按压”真的有效吗？",
      "answer": "均为中国戒烟门诊推荐的本土化方法：5分钟法则可降低70%的即时烟瘾，合谷穴/内关穴按压能缓解戒断期烦躁，配合替代行为（如嚼口香糖）效果更佳。"
    },
    {
      "question": "知识库的内容可以收藏或分享给家人吗？",
      "answer": "目前暂不支持收藏/分享功能，可截图知识库文本内容，未来可以通过“家庭支持”页面将戒烟知识点发送给家人。"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaqsDataCubit, FaqsDataState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.green[50], // 改为浅绿色背景
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.green.shade600, // 改为绿色
            title: const Text(
              "常见问题",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 25),
              child: Center(
                child: Column(
                  children: _appFaqList
                      .map((faq) => FaqItem(
                    question: faq["question"]!,
                    answer: faq["answer"]!,
                  ))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}