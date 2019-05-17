# **研究所課程 : 系統晶片整合設計實驗**
---

這個課主要教我們使用 vivado 設計 ip、將 ip 加入 PL 中、C code 與 V code 一起運作、timing 的除錯等等

總共有 7 個實驗，第 7 個實驗 從 SD card 讀入一個 yuv 格式的影片檔，透過寫好的 sobel filter 濾波後即時顯示於螢幕上

大部分同學都以第 7 個實驗為基礎設計自己的期末專題

---

我的專題設計 Median Filter 與 Laplacian Filter，相較於 sobel filter 是ㄧ階濾波器

Laplacian Filter 是二階濾波器，對於雜訊的反應更加明顯，因此 data flow 先經過 Median Filter 的模糊處理，將雜訊去除

閱讀過[相關文獻](https://wenku.baidu.com/view/f4b36009581b6bd97f19ea5f.html?rec_flag=default&sxts=1558001339188)後，Median Filter 設計如下：

![Median Filter](https://i.imgur.com/bMVEpjD.png)

[程式碼](./ip_repo/cic.narl.org.tw_user_filter_top_v4_0/package_filter_top_v4_0.srcs/sources_1/imports/verilog_filter_top_v4_0/Median_filter.v)：
**soc_hw / ip_repo / cic.narl.org.tw_user_filter_top_v4_0 / package_filter_top_v4_0.srcs / sources_1 / imports / verilog_filter_top_v4_0 / Median_filter.v**

#### 另外在 [**filter_core.v**](ip_repo/cic.narl.org.tw_user_filter_top_v4_0/package_filter_top_v4_0.srcs/sources_1/imports/verilog_filter_top_v4_0/filter_core.v) 中加入下列程式碼：(500 行開始)

```
wire    [DBITS - 1:0]   MedianValue;
reg     [DBITS - 1:0]   MedianValue_core;

wire    [DBITS - 1:0]   MF_Pix_0_0,MF_Pix_0_1,MF_Pix_0_2;
wire    [DBITS - 1:0]   MF_Pix_1_0,MF_Pix_1_1,MF_Pix_1_2;
wire    [DBITS - 1:0]   MF_Pix_2_0,MF_Pix_2_1,MF_Pix_2_2;

assign MF_Pix_0_0 = r_Pix_0_0;
assign MF_Pix_0_1 = r_Pix_0_1;
assign MF_Pix_0_2 = r_Pix_0_2;
assign MF_Pix_1_0 = r_Pix_1_0;
assign MF_Pix_1_1 = r_Pix_1_1;
assign MF_Pix_1_2 = r_Pix_1_2;
assign MF_Pix_2_0 = r_Pix_2_0;
assign MF_Pix_2_1 = r_Pix_2_1;
assign MF_Pix_2_2 = r_Pix_2_2;

Median_Filter#(
    .DBITS ( DBITS ))
Median_filter_i(
	.RST( RST ),
	.CLK( CLK ),
	.Pix_0_0( MF_Pix_0_0 ),
	.Pix_0_1( MF_Pix_0_1 ),
	.Pix_0_2( MF_Pix_0_2 ),
	.Pix_1_0( MF_Pix_1_0 ),
	.Pix_1_1( MF_Pix_1_1 ),
	.Pix_1_2( MF_Pix_1_2 ),
	.Pix_2_0( MF_Pix_2_0 ),
	.Pix_2_1( MF_Pix_2_1 ),
	.Pix_2_2( MF_Pix_2_2 ),
	.MedianValue( MedianValue )
);

//Median_Filter
always @(posedge clk)
    if (rst)
	    MedianValue_core <= 0;
	else 
	    MedianValue_core <= MedianValue;
```

---

#### Laplacian Filter 的 kernel 如下：
![Laplacian Filter](https://i.imgur.com/rDWwXQP.png)

#### 另外在 [**filter_core.v**](ip_repo/cic.narl.org.tw_user_filter_top_v4_0/package_filter_top_v4_0.srcs/sources_1/imports/verilog_filter_top_v4_0/filter_core.v) 中加入下列程式碼：(570 行開始)

```
assign s_sum_Gx = filter_bypass ? {3'b0 , r_Pix_1_1} :
                                                        ( {3'b0 , MedianValue_core }  );
	
assign s_sum_Gy = filter_bypass ? {3'b0 , r_Pix_1_1} :
                                                        ({2'b0 , r_Pix_1_1 , 1'b0} - {3'b0 , r_Pix_1_2} - {3'b0 , r_Pix_1_0} +
                                                         {2'b0 , r_Pix_1_1 , 1'b0} - {3'b0 , r_Pix_0_1} + {3'b0 , r_Pix_2_1} );
```
---

最後用 vivado 將這整個實驗燒錄進 Zedboard，成果如下：

[![Watch the video](https://img.youtube.com/vi/xuBknwYBclg/maxresdefault.jpg)](https://youtu.be/xuBknwYBclg)

