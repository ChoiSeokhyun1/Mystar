package dto.pve;

import lombok.Data;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Data
public class ScriptDTO {
    private int    scriptId;
    private int    myBuildId;
    private int    oppBuildId;
    private String result;      // WIN / LOSE
    private String content;     // 줄바꿈 구분 대본
    private Date   createdAt;

    // 조회 시 편의용 (JOIN)
    private String myBuildName;
    private String oppBuildName;

    public List<String> getLines() {
        if (content == null || content.trim().isEmpty()) return List.of();
        return Arrays.asList(content.split("\\r?\\n"));
    }
}