`timescale 1ns/1ps
// ============================================================================
// spi_master.v — SPI Master (передавач/приймач), режим 0 (CPOL = 0, CPHA = 0)
// Лабораторна робота №3, варіант 6: протокол SPI, мова Verilog
//
// Формат обміну: 8 біт, старшим бітом вперед (MSB first), повний дуплекс.
//   - SCLK у стані спокою = 0 (CPOL = 0);
//   - дані виставляються на MOSI/MISO по спаду SCLK і зчитуються по фронту (CPHA = 0);
//   - CS_N (Slave Select) активний низьким рівнем і утримується на час усього байта.
//
// Частота SCLK = f_clk / (2 * CLK_DIV). Для f_clk = 50 МГц і CLK_DIV = 5 → 5 МГц.
// ============================================================================
module spi_master #(
    parameter CLK_DIV = 5              // кількість тактів clk на половину періоду SCLK (>= 4)
) (
    input  wire       clk,             // системний такт
    input  wire       rst,             // синхронне скидання, активний 1
    // інтерфейс користувача
    input  wire       start,           // імпульс запуску передачі (1 такт)
    input  wire [7:0] tx_data,         // байт для передачі Slave-пристрою
    output reg  [7:0] rx_data,         // байт, прийнятий від Slave
    output reg        busy,            // 1 — триває обмін
    output reg        done,            // імпульс 1 такт: обмін завершено, rx_data дійсний
    // лінії SPI
    output reg        sclk,            // тактовий сигнал SPI (генерує Master)
    output reg        mosi,            // Master Out, Slave In
    input  wire       miso,            // Master In, Slave Out
    output reg        cs_n             // вибір Slave, активний 0
);

    // ---- стани скінченного автомата (FSM) ----
    localparam [1:0] S_IDLE     = 2'd0,   // очікування команди start
                     S_TRANSFER = 2'd1,   // генерація 8 періодів SCLK, зсув даних
                     S_DONE     = 2'd2;   // зняття CS_N, видача результату

    reg [1:0] state;
    reg [7:0] div_cnt;    // дільник частоти: рахує такти до наступного перемикання SCLK
    reg [3:0] edge_cnt;   // лічильник півперіодів SCLK: 0..15 (8 фронтів + 8 спадів)
    reg [7:0] tx_sr;      // зсувний регістр передавача
    reg [7:0] rx_sr;      // зсувний регістр приймача

    always @(posedge clk) begin
        if (rst) begin
            state    <= S_IDLE;
            sclk     <= 1'b0;
            mosi     <= 1'b0;
            cs_n     <= 1'b1;
            busy     <= 1'b0;
            done     <= 1'b0;
            rx_data  <= 8'h00;
            div_cnt  <= 8'd0;
            edge_cnt <= 4'd0;
            tx_sr    <= 8'h00;
            rx_sr    <= 8'h00;
        end else begin
            done <= 1'b0;                          // done — лише один такт
            case (state)
                // ---------------------------------------------------------
                S_IDLE: begin
                    sclk <= 1'b0;
                    cs_n <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        tx_sr    <= tx_data;       // завантажуємо байт
                        mosi     <= tx_data[7];    // старший біт виставляємо до першого фронту
                        cs_n     <= 1'b0;          // вибираємо Slave
                        busy     <= 1'b1;
                        div_cnt  <= 8'd0;
                        edge_cnt <= 4'd0;
                        state    <= S_TRANSFER;
                    end
                end
                // ---------------------------------------------------------
                S_TRANSFER: begin
                    if (div_cnt == CLK_DIV - 1) begin
                        div_cnt  <= 8'd0;
                        sclk     <= ~sclk;         // перемикаємо SCLK
                        edge_cnt <= edge_cnt + 4'd1;
                        if (sclk == 1'b0) begin
                            // фронт SCLK (0 -> 1): зчитуємо біт з MISO
                            rx_sr <= {rx_sr[6:0], miso};
                        end else begin
                            // спад SCLK (1 -> 0): виставляємо наступний біт на MOSI
                            if (edge_cnt == 4'd15) begin
                                state <= S_DONE;   // передано всі 8 біт
                            end else begin
                                tx_sr <= {tx_sr[6:0], 1'b0};
                                mosi  <= tx_sr[6];
                            end
                        end
                    end else begin
                        div_cnt <= div_cnt + 8'd1;
                    end
                end
                // ---------------------------------------------------------
                S_DONE: begin
                    cs_n    <= 1'b1;               // знімаємо вибір Slave
                    mosi    <= 1'b0;
                    busy    <= 1'b0;
                    rx_data <= rx_sr;              // видаємо прийнятий байт
                    done    <= 1'b1;
                    state   <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule

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
