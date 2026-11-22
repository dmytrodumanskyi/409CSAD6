// ============================================================================
// spi_slave.v — SPI Slave, режим 0 (CPOL = 0, CPHA = 0), 8 біт, MSB first
// Лабораторна робота №3, варіант 6. Використовується як "зовнішній пристрій"
// у тестбенчі та демонструє логіку приймача (Rx) з боку Slave.
//
// Вхідні лінії SCLK, CS_N, MOSI асинхронні відносно clk, тому проходять через
// двотригерні синхронізатори. Частота clk має бути щонайменше у 8 разів
// вищою за частоту SCLK (для 50 МГц і SCLK = 5 МГц — у 10 разів).
// ============================================================================
module spi_slave (
    input  wire       clk,             // системний такт Slave
    input  wire       rst,             // синхронне скидання, активний 1
    // лінії SPI
    input  wire       sclk,
    input  wire       cs_n,
    input  wire       mosi,
    output reg        miso,
    // інтерфейс користувача
    input  wire [7:0] tx_data,         // байт, який Slave відправить Master-у
    output reg  [7:0] rx_data,         // байт, прийнятий від Master
    output reg        rx_valid         // імпульс 1 такт: rx_data дійсний
);

    // ---- синхронізатори (2 тригери) + третій тригер для детекції фронтів ----
    reg [2:0] sclk_s, cs_s;
    reg [1:0] mosi_s;
    always @(posedge clk) begin
        sclk_s <= {sclk_s[1:0], sclk};
        cs_s   <= {cs_s[1:0],   cs_n};
        mosi_s <= {mosi_s[0],   mosi};
    end

    wire sclk_rise = (sclk_s[2:1] == 2'b01);   // фронт SCLK
    wire sclk_fall = (sclk_s[2:1] == 2'b10);   // спад SCLK
    wire cs_fall   = (cs_s[2:1]   == 2'b10);   // початок кадру (CS_N 1 -> 0)
    wire cs_active = ~cs_s[1];

    reg [7:0] tx_sr, rx_sr;   // зсувні регістри
    reg [2:0] bit_cnt;        // номер прийнятого біта 0..7

    always @(posedge clk) begin
        if (rst) begin
            miso     <= 1'b0;
            rx_data  <= 8'h00;
            rx_valid <= 1'b0;
            tx_sr    <= 8'h00;
            rx_sr    <= 8'h00;
            bit_cnt  <= 3'd0;
        end else begin
            rx_valid <= 1'b0;
            if (cs_fall) begin
                // початок кадру: завантажуємо байт для відповіді, MSB одразу на MISO
                tx_sr   <= tx_data;
                miso    <= tx_data[7];
                bit_cnt <= 3'd0;
            end else if (cs_active) begin
                if (sclk_rise) begin
                    // фронт: зчитуємо біт з MOSI
                    rx_sr   <= {rx_sr[6:0], mosi_s[1]};
                    bit_cnt <= bit_cnt + 3'd1;
                    if (bit_cnt == 3'd7) begin
                        rx_data  <= {rx_sr[6:0], mosi_s[1]};
                        rx_valid <= 1'b1;
                    end
                end else if (sclk_fall) begin
                    // спад: виставляємо наступний біт на MISO
                    tx_sr <= {tx_sr[6:0], 1'b0};
                    miso  <= tx_sr[6];
                end
            end
        end
    end

endmodule
